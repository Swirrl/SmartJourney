class Interval

  include Tripod::Resource
  include DateTimeValidator
  include BeforeSave
  include ActiveModel::Validations::Callbacks

  def self.rdf_type
    RDF::URI("http://purl.org/NET/c4dm/timeline.owl#Interval")
  end

  def self.graph_uri
    RDF::URI("http://data.smartjourney.co.uk/graph/reports") # goes in the reports graph
  end

  def self.begins_at_predicate
    RDF::URI('http://purl.org/NET/c4dm/timeline.owl#beginsAtDateTime')
  end

  def self.ends_at_predicate
    RDF::URI('http://purl.org/NET/c4dm/timeline.owl#endsAtDateTime')
  end

  field :begins_at, Interval.begins_at_predicate, :datatype => RDF::XSD.dateTime
  field :ends_at, Interval.ends_at_predicate, :datatype => RDF::XSD.dateTime
  field :rdf_type, RDF.type
  field :label, RDF::RDFS.label

  validates :label, :begins_at, :rdf_type, :presence => true
  validate :validate_begin_and_end_times

  # the order of these matters!
  before_validation :set_begins_at
  before_validation :set_label

  # override initialise
  def initialize(uri=nil, graph_uri=nil)
    super(uri || RDF::URI("http://data.smartjourney.co.uk/id/interval/#{Guid.new.to_s}"), graph_uri || Interval.graph_uri)
    self.rdf_type ||= Interval.rdf_type
  end

   def self.all
    query = "
      SELECT ?uri (<#{Interval.graph_uri}> AS ?graph)
      WHERE {
        GRAPH <#{Interval.graph_uri}> {
           ?uri a <#{Interval.rdf_type}> .
        }
      }"
    self.where(query)
  end

  private

  def validate_begin_and_end_times
    Rails.logger.debug "in interval validate begin/end"
    errors.add(:begins_at, 'must be a valid datetime') unless is_valid_datetime? self.begins_at
    (errors.add(:ends_at, 'must be a valid datetime') unless is_valid_datetime?(self.ends_at) ) if self.ends_at
  end

  def set_begins_at
    if self.new_record?
      self.begins_at = Time.now unless self.begins_at  # only for new records.
    end
  end

  def set_label
    self.label = "begins: #{I18n.l(Time.parse(self.begins_at), :format => :long)}" rescue nil
    self.label += ", ends:  #{I18n.l(Time.parse(self.ends_at), :format => :long)}" if self.ends_at rescue nil
  end

  def before_save
    Rails.logger.debug "in interval before save"

    # make sure times in the db are full iso format
    self.begins_at = Time.parse(self.begins_at).getlocal.iso8601().to_s if is_valid_datetime?(self.begins_at) rescue nil
    ((self.ends_at = Time.parse(self.ends_at).getlocal.iso8601().to_s if is_valid_datetime?(self.ends_at) ) if self.ends_at) rescue nil
  end

end