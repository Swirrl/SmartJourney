class Report

  include Tripod::Resource

  # need to define this before we use it below.
  def self.datetime_predicate
    RDF::URI('http://datetime')
  end

  field :description, 'http://description'
  field :datetime, self.datetime_predicate.to_s, :datatype => RDF::XSD.datetime
  field :latitude, 'http://lat', :datatype => RDF::XSD.double
  field :longitude, 'http://long', :datatype => RDF::XSD.double
  field :rdf_type, RDF.type

  validates :datetime, :latitude, :longitude, :report_type, :zone, :presence => true
  validates :latitude, :longitude, :format => { :with => %r([0-9]+\.[0-9]*) }
  validate :check_format_of_datetime

  # override innitialise
  def initialize(uri=nil, graph_uri=nil)
    super(uri || Report.generate_unique_uri, graph_uri || Report.graph_uri)
    self.rdf_type ||= Report.rdf_type
    self.datetime ||= DateTime.now
  end

  def reporter
    # todo
  end

  def reporter=

  end

  # get an instance of a zone object, based on the uri in this report's zone predicate
  def zone
    unless self[Report.zone_predicate].empty?
      Zone.new(self[Report.zone_predicate], Zone.graph_uri)
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
    unless self[Report.report_type_predicate].empty?
      ReportType.new(self[Report.report_type_predicate], ReportType.graph_uri)
    else
      nil
    end
  end

  def report_type=(new_report_type)
    self[Report.report_type_predicate] = new_report_type.uri
  end

  def report_type_uri
    self[Report.report_type_predicate]
  end

  def self.report_type_predicate
    RDF::URI('http://reporttype')
  end

  def self.zone_predicate
    RDF::URI('http://zone')
  end

  def self.all
    query = "
      SELECT ?uri ?dt (<#{Report.graph_uri}> AS ?graph)
      WHERE {
        GRAPH <#{Report.graph_uri}> {
          ?uri a <#{Report.rdf_type.to_s}> .
          ?uri <#{Report.datetime_predicate.to_s}> ?dt .
        }
      }
      ORDER BY DESC(?dt)"
    self.where(query)
  end

  def self.generate_unique_uri
    g = Guid.new
    RDF::URI("http://#{PublishMyData.local_domain}/id/report/#{g.to_s}")
  end

  def self.graph_uri
    RDF::URI("http://#{PublishMyData.local_domain}/graph/reports")
  end

  def self.rdf_type
    RDF::URI("http://#{PublishMyData.local_domain}/reports")
  end

  def self.datetime_predicate
    RDF::URI('http://datetime')
  end

  # associates this report with a single zone, based on this report's lat-longs.
  # TODO: call this before every save time? Use callbacks? (need to add to tripod).
  def associate_zone
    self.zone = Zone.zone_for_lat_long(self.latitude.to_f, self.latitude.to_f)
  end

  protected

  def check_format_of_datetime
    begin
      DateTime.parse(self.datetime)
    rescue
      errors.add(:datetime, "is invalid")
    end
  end
end