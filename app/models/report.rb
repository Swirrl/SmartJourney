class Report

  include Tripod::Resource
  include BeforeSave
  include DateTimeValidator
  include ActiveModel::Validations::Callbacks

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

  # PROXIED VALIDATIONS
  validate :validate_location
  validate :validate_begin_and_end_times
  # END PROXIED VALIDATIONS

  before_validation :set_created_at
  before_validation :set_label

  # override initialise
  def initialize(uri=nil, graph_uri=nil)
    super(uri || RDF::URI("http://data.smartjourney.co.uk/id/report/#{Guid.new.to_s}"), graph_uri || Report.graph_uri)
    self.rdf_type ||= Report.rdf_type
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

  def zone
    self.incident.place.zone if self.incident && self.incident.place
  end

  def incident_begins_at
    begin
      Time.parse(self.incident.interval.begins_at).strftime(Report::UI_DATE_FORMAT) if self.incident && self.incident.interval && self.incident.interval.begins_at
    rescue
      self.incident.interval.begins_at
    end
  end

  def incident_ends_at
    begin
      Time.parse(self.incident.interval.ends_at).strftime(Report::UI_DATE_FORMAT) if self.incident && self.incident.interval && self.incident.interval.ends_at
    rescue
      self.incident.interval.ends_at
    end
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

    Rails.logger.debug('save_report_and_children')
    interval = incident.interval
    place = incident.place

    Rails.logger.debug('saving place...')
    place_success = place.save(opts)
    Rails.logger.debug("place success: #{place_success}")

    Rails.logger.debug('saving interval...')
    interval_success = interval.save(opts)
    Rails.logger.debug("interval success: #{interval_success}")

    Rails.logger.debug('saving incident...')
    incident_success = incident.save(opts)
    Rails.logger.debug("incident success: #{incident_success}")

    Rails.logger.debug('saving report...')
    report_success = self.save(opts)
    Rails.logger.debug("report success: #{report_success}")

    Rails.logger.debug ("PLACE ERRORS: " + place.errors.messages.inspect) unless place_success
    Rails.logger.debug ("INTERVAL ERRORS: " + interval.errors.messages.inspect) unless interval_success
    Rails.logger.debug ("INCIDENT ERRORS: " + incident.errors.messages.inspect) unless incident
    Rails.logger.debug ("REPORT ERRORS: " + self.errors.messages.inspect) unless report_success

    success = place_success && interval_success && incident_success && report_success

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

          ?interval <#{Interval.begins_at_predicate.to_s}> ?begins .
          OPTIONAL { ?interval <#{Interval.ends_at_predicate.to_s}> ?ends . }

          FILTER (
            # begin in the past
            (?begins <= \"#{Time.now.iso8601()}\"^^xsd:dateTime)
            &&
            # don't end or end in future.
            (
              (!bound( ?ends )) ||
              (?ends >= \"#{Time.now.iso8601()}\"^^xsd:dateTime)
            )
          ) .
        }
      }
      ORDER BY DESC(?created)"
    query += " LIMIT #{limit}" if limit

    self.where(query, {uri_variable: 'report'})
  end

  def self.future_reports(limit=nil)
    query = "
      PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
      SELECT ?report (<#{Report.graph_uri}> AS ?graph)
      WHERE {
        GRAPH <#{Report.graph_uri}> {
          ?report a <#{Report.rdf_type}> .
          ?report <#{Report.created_at_predicate.to_s}> ?created .
          ?report <#{Report.incident_predicate.to_s}> ?incident .
          ?incident <#{Incident.interval_predicate.to_s}> ?interval .

          ?interval <#{Interval.begins_at_predicate.to_s}> ?begins .
          OPTIONAL { ?interval <#{Interval.ends_at_predicate.to_s}> ?ends . }

          FILTER (
            # begin in the future
            (?begins > \"#{Time.now.iso8601()}\"^^xsd:dateTime)
            &&
            # don't end or end in future.
            (
              (!bound( ?ends )) ||
              (?ends >= \"#{Time.now.iso8601()}\"^^xsd:dateTime)
            )
          ) .
        }
      }
      ORDER BY DESC(?created)
    "

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
      created_at: Time.parse(self.created_at).to_s(:long),
      incident_begins_at: Time.parse(self.incident_begins_at).to_s(:long),
      incident_begins_in_future: self.incident_begins_in_future?,
      incident_ends_in_future: self.incident_ends_in_future?,
      latitude: self.latitude,
      longitude: self.longitude,
      tags: self.tags,
      tags_string: self.tags_string,
      guid: self.guid,

    }
    hash[:creator] = creator.screen_name if creator
    hash[:incident_ends_at] = Time.parse(self.incident_ends_at).to_s(:long) if self.incident_ends_at
    hash
  end

  def report_update_recipients(updating_user)
    Rails.logger.debug(updating_user.inspect)
    recipients = []

    current_zone = self.zone
    Rails.logger.debug "current zone #{current_zone.uri.to_s}"

    User.all.each do |user|
      if (
          (user.uri != updating_user.uri) && # don't send to updating user.
          (
            ( user.receive_report_emails && self.creator.uri == user.uri ) || # they want emails about their own reports, and this is one of theirs
            ( user.receive_zone_emails && user.in_zones?(current_zone) ) # or they want zone emails, and this report is in one of their zones.
          )
        )
        recipients << user.email
      end
    end

    recipients
  end

  def new_report_recipients(creating_user)
    Rails.logger.debug(creating_user.inspect)

    recipients = []

    current_zone = self.zone
    Rails.logger.debug "current zone #{current_zone.uri.to_s}"

    User.all.each do |user|
      if (
          (user.uri != creating_user.uri) && # don't send to creating user.
          (
            ( user.receive_zone_emails && user.in_zones?(current_zone) ) # they want zone emails, and this report is in one of their zones.
          )
        )
        recipients << user.email
      end
    end

    recipients
  end

  # deletes all report, incidents, places, intervals, comments
  def self.delete_all_from_graph
    Tripod::SparqlClient::Update::update(
      "DELETE {graph <#{Report.graph_uri}> {?s ?p ?o}}
      WHERE {graph <#{Report.graph_uri}> {?s ?p ?o}};"
    )
  end

  def self.expire_old_reports!(age_in_seconds)
    reports_expired = 0
    Report.open_reports.each do |r|
      if (!r.incident_ends_at) && (Time.parse(r.incident_begins_at) < Time.now.advance(:seconds => -age_in_seconds))
        interval = r.incident.interval
        interval.ends_at = Time.now
        interval.save!
        reports_expired +=1
      end
    end
    reports_expired
  end

  private

  def set_created_at
    self.created_at = Time.now if self.new_record?
  end

  def set_label
    self.label = "Report:"
    self.label += " #{self.description.truncate(20)}" if self.description
    self.label += ", created #{Time.parse(self.created_at).to_s(:long)}"
    self.label += " by #{self.creator.screen_name}" if self.creator
  end

  def before_save
    self.created_at = Time.now if self.new_record? # make sure the created at time is just before save
  end

  def validate_begin_and_end_times
    # proxy the errors from interval.
    if incident && incident.interval
      errors[:incident_begins_at] += incident.interval.errors[:begins_at] if incident.interval.errors.include?(:begins_at)
      errors[:incident_ends_at] += incident.interval.errors[:ends_at] if incident.interval.errors.include?(:ends_at)
    end

  end

  def validate_location
    # proxy errors from incident, but make them more user friendly for report form
    if incident && incident.place
      errors.add(:location, 'must be supplied (and in Aberdeenshire)') if incident.place.errors.any?
    end
  end


end