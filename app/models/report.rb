class Report

  include Tripod::Resource

  # need to define this before we use it below.
  def self.created_at_predicate
    RDF::URI('http://purl.org/dc/terms/created')
  end

  def self.status_predicate
    RDF::URI("http://#{PublishMyData.local_domain}/def/reportStatus")
  end

  def self.creator_predicate
    RDF::URI('http://rdfs.org/sioc/ns#hasCreator')
  end

  def self.zone_predicate
    RDF::URI("http://#{PublishMyData.local_domain}/def/zone")
  end

  def self.graph_uri
    RDF::URI("http://#{PublishMyData.local_domain}/graph/reports")
  end

  def self.rdf_type
    RDF::URI("http://#{PublishMyData.local_domain}/reports")
  end

  # TODO: implement callbacks.
  # before_create :set_datetime
  # before_save :set_label

  field :description, 'http://purl.org/dc/terms/description'
  field :created_at, self.created_at_predicate.to_s, :datatype => RDF::XSD.dateTime
  field :latitude, 'http://www.w3.org/2003/01/geo/wgs84_pos#lat', :datatype => RDF::XSD.double
  field :longitude, 'http://www.w3.org/2003/01/geo/wgs84_pos#long', :datatype => RDF::XSD.double
  field :rdf_type, RDF.type, :multivalued => true
  field :status, Report.status_predicate
  field :label, RDF::RDFS.label

  validates :created_at, :latitude, :longitude, :zone, :report_type, :presence => true
  validates :latitude, :longitude, :format => { :with => %r([0-9]+\.[0-9]*) }

  # override initialise
  def initialize(uri=nil, graph_uri=nil)
    unless (uri.class == Hash || uri.class == HashWithIndifferentAccess) # CanCan tries to pass a hash sometimes (e.g. for create)
      super(uri || Report.generate_unique_uri, graph_uri || Report.graph_uri)
      self.status ||= RDF::URI.new(Status::CURRENT_URI)
      self.rdf_type = [Report.rdf_type] # set the base type
    end
  end

  # returns a user object.
  def creator
    unless self[Report.creator_predicate].empty?
      User.where(:uri => self[Report.creator_predicate].first.to_s).first
    else
      nil
    end
  end

  # pass in an instance of a user object.
  def creator=(new_user)
    self[Report.creator_predicate] = new_user.uri
  end

  # get an instance of a zone object, based on the uri in this report's zone predicate
  def zone
    unless self[Report.zone_predicate].empty?
      Zone.find(self[Report.zone_predicate].first)
    else
      nil
    end
  end

  # make an association to a zone by passing in a zone object.
  def zone=(new_zone)
    self[Report.zone_predicate] = new_zone.uri
  end

  def zone_uri
    self[Report.zone_predicate]
  end

  def report_type
    begin
      ReportType.find(report_type_uri)
    rescue
      nil
    end
  end

  def report_type_uri
    # the report type is defined by the type of the report, which isn't just ReportType
    report_type_uri = (self.rdf_type.map{ |r| r.to_s } - [Report.rdf_type.to_s]).first # set subtraction
  end

  def report_type_uri=(new_report_type_uri)
    self[RDF.type] = [
      Report.rdf_type, # always 'Report' base type...
      RDF::URI.new(new_report_type_uri).to_s # ...plus report subtype.
    ]
  end

  def self.all
    query = "
      SELECT ?uri (<#{Report.graph_uri}> AS ?graph)
      WHERE {
        GRAPH <#{Report.graph_uri}> {
          ?uri <#{Report.created_at_predicate.to_s}> ?dt .
        }
      }
      ORDER BY DESC(?dt)"
    self.where(query)
  end

   def self.recent_open_reports(time, seconds_old=(60*60*24), limit=nil)
    query = "
      PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
      SELECT ?uri (<#{Report.graph_uri}> AS ?graph)
      WHERE {
        GRAPH <#{Report.graph_uri}> {
          ?uri <#{Report.created_at_predicate.to_s}> ?dt .
          ?uri <#{Report.status_predicate.to_s}> <#{Status::CURRENT_URI}> .
        }
        FILTER ( ?dt > \"#{time.advance(:seconds => -seconds_old).iso8601()}\"^^xsd:dateTime ) .
      }
      ORDER BY DESC(?dt)"
    query += " LIMIT #{limit}" if limit
    puts query

    Rails.logger.debug(query)
    self.where(query)
  end

  def self.generate_unique_uri
    g = Guid.new
    RDF::URI("http://#{PublishMyData.local_domain}/id/report/#{g.to_s}")
  end

  # associates this report with a single zone, based on this report's lat-longs.
  # TODO: call this before every save time? Use callbacks? (need to add to tripod).
  def associate_zone
    self.zone = Zone.zone_for_lat_long(self.latitude.to_f, self.latitude.to_f)
  end

  def as_json(options = nil)
    hash = {
      description: self.description,
      datetime: I18n.l(Time.parse(self.created_at), :format => :long),
      latitude: self.latitude,
      longitude: self.longitude
    }
    hash[:reportType] = self.report_type.label if self.report_type
    hash[:creator] = creator.screen_name if creator
    hash
  end

  def self.delete_all
    Tripod::SparqlClient::Update::update(
      "DELETE {graph <#{Report.graph_uri}> {?s ?p ?o}}
      WHERE {graph <#{Report.graph_uri}> {?s ?p ?o}}"
    )
  end

  protected

  def check_format_of_created_at
    begin
      DateTime.parse(self.created_at.to_s)
    rescue
      errors.add(:datetime, "is invalid")
    end
  end

  def set_datetime
    self.created_at = Time.now
  end

  def set_label
    self.label = 'iamalabel'
  end

end