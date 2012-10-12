class Report

  include Tripod::Resource
  include BeforeSave
  include DateTimeValidator

  UI_DATE_FORMAT ="%Y-%m-%d %H:%M"

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

  validates :created_at, :label, :rdf_type, :description, :presence => true
  validates :incident, :presence => true #associated incident

  # allow validation of lat and long here by using the proxy methods
  validates :latitude, :longitude, :format => { :with => %r([0-9]+\.[0-9]*) }, :if => Proc.new {|p| (p.latitude.present? && p.longitude.present?) }
  validates :longitude, :latitude, :presence => true
  # likewise, begin end times (from interval)
  validate :validate_begin_and_end_times

  # override initialise
  def initialize(uri=nil, graph_uri=nil)
    super(uri || RDF::URI("http://data.smartjourney.co.uk/id/report/#{Guid.new.to_s}"), graph_uri || Report.graph_uri)
    self.rdf_type ||= Report.rdf_type

    #these will get stomped on by before_save, but they make it valid for now...
    self.label ||= "report"
    self.created_at ||= Time.now
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

  def incident_begins_at
    Time.parse(self.incident.interval.begins_at).strftime(Report::UI_DATE_FORMAT) if self.incident && self.incident.interval && self.incident.interval.begins_at
  end

  def incident_ends_at
    Time.parse(self.incident.interval.ends_at).strftime(Report::UI_DATE_FORMAT) if self.incident && self.incident.interval && self.incident.interval.ends_at
  end

  def incident_begins_in_future?
    Time.parse(incident_begins_at) >= Time.now
  end

  def incident_ends_in_future?
    incident_ends_at && Time.parse(incident_ends_at) >= Time.now
  end

  # END PROXIED METHODS

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
      @incident = Incident.find(self[Report.incident_predicate].first)
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

    interval = incident.interval
    place = incident.place

    Rails.logger.debug("about to save interval")
    interval_success = interval.save(opts)
    Rails.logger.debug("saved interval")
    place_success = place.save(opts)
    incident_success = incident.save(opts)
    report_success = self.save(opts)

    Rails.logger.debug ("INTERVAL ERRORS: " + interval.errors.messages.inspect) unless interval_success
    Rails.logger.debug ("INCIDENT ERRORS: " + incident.errors.messages.inspect) unless incident
    Rails.logger.debug ("PLACE ERRORS: " + place.errors.messages.inspect) unless place_success
    Rails.logger.debug ("REPORT ERRORS: " + self.errors.messages.inspect) unless report_success

    success = interval_success && place_success && incident_success && report_success

  end

  def self.all
    query = "
      SELECT ?uri (<#{Report.graph_uri}> AS ?graph)
      WHERE {
        GRAPH <#{Report.graph_uri}> {
          ?uri a <#{Report.rdf_type}> .
        }
      }"
    self.where(query)
  end

  def self.open_reports(limit=nil)
    query = "
      PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
      SELECT ?report (<#{Report.graph_uri}> AS ?graph)
      WHERE {
        GRAPH <#{Report.graph_uri}> {
          ?report a <#{Report.rdf_type}> .
          ?report <#{Report.created_at_predicate.to_s}> ?created .
          ?report <#{Report.incident_predicate.to_s}> ?incident .
          ?incident <#{Incident.interval_predicate.to_s}> ?interval .
          OPTIONAL { ?interval <#{Interval.ends_at_predicate}> ?ends . }

          FILTER (
            (!bound( ?ends )) ||
            (?ends > \"#{Time.now.iso8601()}\"^^xsd:dateTime)
          ) .
        }
      }
      ORDER BY DESC(?created)"
    query += " LIMIT #{limit}" if limit

    self.where(query, {uri_variable: 'report'})
  end

  def guid
    self.uri.to_s.split("/").last
  end

  def to_param
    guid
  end

  def id
    guid
  end

  def as_json(options = nil)
    hash = {
      description: self.description,
      created_at: I18n.l(Time.parse(self.created_at), :format => :long),
      incident_begins_at: I18n.l(Time.parse(self.incident_begins_at), :format => :long),
      incident_begins_in_future: self.incident_begins_in_future?,
      incident_ends_in_future: self.incident_ends_in_future?,
      latitude: self.latitude,
      longitude: self.longitude,
      tags: self.tags,
      tags_string: self.tags_string,
      guid: self.guid,

    }
    hash[:creator] = creator.screen_name if creator
    hash[:incident_ends_at] = I18n.l(Time.parse(self.incident_ends_at), :format => :long) if self.incident_ends_at
    hash
  end

  # deletes all report, incidents, places, intervals, comments
  def self.delete_all_from_graph
    Tripod::SparqlClient::Update::update(
      "DELETE {graph <#{Report.graph_uri}> {?s ?p ?o}}
      WHERE {graph <#{Report.graph_uri}> {?s ?p ?o}};"
    )
  end

  private

  def before_save
    self.created_at = Time.now if self.new_record?

    self.label = "Report: #{self.description.truncate(20)}"
    self.label += ", created #{I18n.l(Time.parse(self.created_at), :format => :long)}"
    self.label += " by #{self.creator.screen_name}" if self.creator
  end

  def validate_begin_and_end_times
    errors.add(:incident_begins_at, 'must be a valid datetime') unless is_valid_datetime? self.incident_begins_at
    (errors.add(:incident_ends_at, 'must be a valid datetime') unless is_valid_datetime?(self.incident_ends_at) ) if self.incident_ends_at
  end


end