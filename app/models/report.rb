class Report

  include Tripod::Resource
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

  def self.comment_predicate
    RDF::URI('http://rdfs.org/sioc/ns#hasReply')
  end

  def self.curated_tags
    ["accident", "roadworks", "road closed", "snow", "flood", "traffic jam"]
  end

  field :created_at, self.created_at_predicate.to_s, :datatype => RDF::XSD.dateTime
  field :rdf_type, RDF.type
  field :label, RDF::RDFS.label
  field :tags, Report.tag_predicate, :multivalued => true
#  field :comments, Report.comment_predicate, :multivalued => true

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

  def check_associations_exist!
    if new_record?
      self.incident = Incident.new unless self.incident
      self.incident.place = Place.new unless self.incident.place
      self.incident.interval = Interval.new unless self.incident.interval
      @interval_changed = @incident_changed = @place_changed = true # all changed.
    end
    # for existing records, they will exist or it wouldn't have been valid
  end

  # PROXIED METHODS

  def latitude
    self.incident.place.latitude if self.incident && self.incident.place
  end

  def latitude=(val)
    check_associations_exist!
    self.incident.place.latitude = val
    @incident_changed = true
    @place_changed = true
  end

  def longitude
    self.incident.place.longitude if self.incident && self.incident.place
  end

  def longitude=(val)
    check_associations_exist!
    self.incident.place.longitude = val
    @place_changed = true
  end

  def description
    self.incident.description if self.incident
  end

  def description=(val)
    check_associations_exist!
    self.incident.description = val
    @incident_changed = true
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

  def incident_begins_at=(val)
    check_associations_exist!
    self.incident.interval.begins_at = val
    @interval_changed = true
  end

  def incident_ends_at
    begin
      Time.parse(self.incident.interval.ends_at).strftime(Report::UI_DATE_FORMAT) if self.incident && self.incident.interval && self.incident.interval.ends_at
    rescue
      self.incident.interval.ends_at
    end
  end

  def incident_ends_at=(val)
    check_associations_exist!
    self.incident.interval.ends_at = val
    @interval_changed = true
  end

  def incident_begins_in_future?
    Time.parse(incident_begins_at) >= Time.now
  end

  def incident_ends_in_future?
    incident_ends_at && Time.parse(incident_ends_at) >= Time.now
  end

  # END PROXIED METHODS

  def comments
    query = "
      SELECT ?uri (<#{Report.graph_uri}> AS ?graph)
      WHERE {
        GRAPH <#{Report.graph_uri}> {
          ?uri a <#{Comment.rdf_type}> .
          <#{self.uri.to_s}> <#{Report.comment_predicate.to_s}> ?uri .
          ?uri <#{Comment.created_at_predicate.to_s}> ?created .
        }
      }
      ORDER BY DESC(?created)"
    Comment.where(query)
  end

  # pass in a comment object
  def add_comment(c)
    self[Report.comment_predicate] = self[Report.comment_predicate] + [c.uri]
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
    self[Report.creator_predicate] = RDF::URI(new_user.uri)
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
    tags_array = tags_string.split(',').map{ |t| t.strip.downcase }.uniq
    self.tags = tags_array
  end

  def tags_string
    self.tags.join(", ")
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
            (?begins <= NOW() )
            &&
            # don't end or end in future.
            (
              (!bound( ?ends )) ||
              (?ends >= NOW() )
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
            (?begins > NOW() )
            &&
            # don't end or end in future.
            (
              (!bound( ?ends )) ||
              (?ends >= NOW() )
            )
          ) .
        }
      }
      ORDER BY DESC(?created)
    "
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
      uri: self.uri.to_s,
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
      status: self.status
    }
    hash[:creator] = creator.screen_name if creator
    hash[:incident_ends_at] = Time.parse(self.incident_ends_at).to_s(:long) if self.incident_ends_at
    hash
  end

  def report_update_alert_recipients(updating_user)
    recipients = []
    current_zone = self.zone

    User.all.each do |user|
      if (
          ((!updating_user) || (user.uri != updating_user.uri)) && # don't send to updating user.
          (
            ( user.receive_report_emails && self.creator && self.creator.uri == user.uri ) || # they want emails about their own reports, and this is one of theirs
            ( user.receive_zone_emails && user.in_zones?(current_zone) ) # or they want zone emails, and this report is in one of their zones.
          )
        )
        recipients << user.email
      end
    end

    recipients
  end

  def new_report_alert_recipients(creating_user)
    recipients = []
    current_zone = self.zone

    User.all.each do |user|
      if (
          ((!creating_user) || (user.uri != creating_user.uri)) && # don't send to creating user.
          (
            ( user.receive_zone_emails && user.in_zones?(current_zone) ) # they want zone emails, and this report is in one of their zones.
          )
        )
        recipients << user.email
      end
    end

    recipients
  end

  def still_open?
    (!self.incident_ends_at) || (Time.parse(self.incident_ends_at) > Time.now)
  end

  def planned?
    (Time.parse(self.incident_begins_at) > Time.now)
  end

  def status
    if still_open?
      planned? ? "Planned" : "Open"
    else
     "Closed"
    end
  end

  def close!
    Rails.logger.debug('closing')
    now = Time.now
    interval = self.incident.interval
    if self.planned?
      interval.begins_at = now
    end
    interval.ends_at = now
    interval.save!
    clear_cache
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
        r.close!
        reports_expired +=1
      end
    end
    reports_expired
  end

  # override save, so that it
  def save(opts={})

    # start a new transaction unless one's passed in
    t = opts[:transaction] ||= Tripod::Persistence::Transaction.new

    place = incident.place
    interval = incident.interval

    place_success = place.save(opts) if @place_changed
    interval_success = interval.save(opts) if @interval_changed
    incident_success = incident.save(opts) if @incident_changed

    self.created_at = Time.now if self.new_record?
    report_success = super(opts)

    Rails.logger.debug ("PLACE ERRORS: " + place.errors.messages.inspect) unless place_success
    Rails.logger.debug ("INTERVAL ERRORS: " + interval.errors.messages.inspect) unless interval_success
    Rails.logger.debug ("INCIDENT ERRORS: " + incident.errors.messages.inspect) unless incident
    Rails.logger.debug ("REPORT ERRORS: " + self.errors.messages.inspect) unless report_success

    success = (
      (!@place_changed || place_success) && # place hasn't changed or it succeeded save
      (!@interval_changed || interval_success) && # interval hasn't changed or it succeeded save
      (!@incident_changed || incident_success) && # incident hasn't changed or it succeeded save
      report_success
    )

    if success
      t.commit
      update_dataset_modified
      clear_cache
    else
      t.abort
    end

    Rails.logger.debug "REPORT SAVE SUCCESS: #{success.inspect}"
    success

  end

  private

  def clear_cache
    Rails.cache.clear
  end

  def set_created_at
    self.created_at = Time.now if self.new_record?
  end

  def set_label
    self.label = "Report:"
    self.label += " #{self.description.truncate(20)}" if self.description
    self.label += ", created #{Time.parse(self.created_at).to_s(:long)}"
    self.label += " by #{self.creator.screen_name}" if self.creator
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
      errors.add(:location, 'must be supplied (and in Aberdeen/Aberdeenshire)') if incident.place.errors.any?
    end
  end

  def update_dataset_modified
    # in local dev mode, the dataset might not be there.
    d = TripodDataset.find("http://data.smartjourney.co.uk/id/dataset/reports") rescue nil
    if d
      d.modified = Time.now
      d.save
    end
  end


end