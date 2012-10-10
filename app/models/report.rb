class Report

  include Tripod::Resource

  # need to define this before we use it below.
  def self.created_at_predicate
    RDF::URI('http://purl.org/dc/terms/created')
  end

  def self.creator_predicate
    RDF::URI('http://rdfs.org/sioc/ns#hasCreator')
  end

  def self.graph_uri
    RDF::URI("http://data.smartjourney.co.uk/graph/reports")
  end

  def self.rdf_type
    RDF::URI("http://data.smartjourney.co.uk/def/Report")
  end

  def self.tag_predicate
    RDF::URI("http://data.smartjourney.co.uk/def/tag")
  end

  def self.incident_predicate
    RDF::URI("http://xmlns.com/foaf/0.1/primaryTopic")
  end

  field :created_at, self.created_at_predicate.to_s, :datatype => RDF::XSD.dateTime
  field :rdf_type, RDF.type
  field :label, RDF::RDFS.label
  field :tags, Report.tag_predicate, :multivalued => true

  validates :created_at,  :label, :rdf_type, :presence => true
  validates :incident, :presence => true #associated incident

  # allow validation of lat and long here by using the proxy methods
  validates :latitude, :longitude, :format => { :with => %r([0-9]+\.[0-9]*) }, :if => Proc.new {|p| (p.latitude.present? && p.longitude.present?) }
  validates :longitude, :latitude, :presence => true
  validates :description, :presence => true

  # override initialise
  def initialize(uri=nil, graph_uri=nil)
    super(uri || RDF::URI("http://data.smartjourney.co.uk/id/report/#{Guid.new.to_s}"), graph_uri || Report.graph_uri)
    self.rdf_type ||= Report.rdf_type
    self.label ||= "a report" # TODO: autogen before_save based on contents.
    self.created_at ||= Time.now # TODO: autogen before_save based on current time then.
  end

  # PROXIED METHODS

  def latitude
    self.incident.place.latitude if self.incident && self.incident.place
  end

  def longitude
    self.incident.place.longitude if self.incident && self.incident.place
  end

  def description
    self.incident.description if self.incident
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

  # returns an incident object.
  def incident
    if @incident
      @incident
    elsif !self[Report.incident_predicate].empty?
      Incident.find(self[Report.incident_predicate].first)
    else
      nil
    end
  end

  # pass in an instance of an incident object.
  def incident=(new_incident)
    @incident = new_incident
    self[Report.incident_predicate] = new_incident.uri
  end

  def tags_string=(tags_string)
    tags_array = tags_string.split(',').map{ |t| t.strip }
    self.tags = tags_array
  end

  def tags_string
    self.tags.join(", ")
  end

  def save_report_and_children(opts={})

    interval_success = incident.interval.save(opts)
    place_success = incident.place.save(opts)
    incident_success = incident.save(opts)
    report_success = self.save(opts)

    success = interval_success && place_success && incident_success && report_success

  end

  def self.all
    query = "
      SELECT ?uri (<#{Report.graph_uri}> AS ?graph)
      WHERE {
        GRAPH <#{Report.graph_uri}> {
          ?uri <#{Report.created_at_predicate.to_s}> ?created .
          ?uri a <#{Report.rdf_type}> .
        }
      }
      ORDER BY DESC(?created)"
    self.where(query)
  end

  def self.recent_open_reports(time, seconds_old=(60*60*24), limit=nil)
    query = "
      PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
      SELECT ?uri (<#{Report.graph_uri}> AS ?graph)
      WHERE {
        GRAPH <#{Report.graph_uri}> {
          ?uri <#{Report.created_at_predicate.to_s}> ?dt .
        }
        FILTER ( ?dt > \"#{time.advance(:seconds => -seconds_old).iso8601()}\"^^xsd:dateTime ) .
      }
      ORDER BY DESC(?dt)"
    query += " LIMIT #{limit}" if limit

    self.where(query)
  end

  def guid
    self.uri.to_s.split("/").last
  end

  def to_param
    guid
  end

  def as_json(options = nil)
    hash = {
      description: self.description,
      datetime: I18n.l(Time.parse(self.created_at), :format => :long),
      latitude: self.latitude,
      longitude: self.longitude,
      tags: self.tags,
      tags_string: self.tags_string
    }
    hash[:creator] = creator.screen_name if creator
    hash
  end

  # deletes all report, incidents, places, intervals, comments
  def self.delete_all_from_graph
    Tripod::SparqlClient::Update::update(
      "DELETE {graph <#{Report.graph_uri}> {?s ?p ?o}}
      WHERE {graph <#{Report.graph_uri}> {?s ?p ?o}}"
    )
  end


end