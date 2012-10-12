class Incident

  include Tripod::Resource
  include BeforeSave

  def self.place_predicate
    RDF::URI("http://purl.org/NET/c4dm/event.owl#place")
  end

  def self.interval_predicate
    RDF::URI("http://purl.org/NET/c4dm/event.owl#time")
  end

  def self.rdf_type
    RDF::URI("http://data.smartjourney.co.uk/def/Incident")
  end

  def self.graph_uri
    RDF::URI("http://data.smartjourney.co.uk/graph/reports") # goes in the reports graph
  end

  field :description, 'http://purl.org/dc/terms/description'
  field :label, RDF::RDFS.label
  field :rdf_type, RDF.type
  validates :label, :rdf_type, :presence => true
  validates :place, :presence => true

   # override initialise
  def initialize(uri=nil, graph_uri=nil)
    super(uri || RDF::URI("http://data.smartjourney.co.uk/id/incident/#{Guid.new.to_s}"), graph_uri || Incident.graph_uri)
    self.rdf_type ||= Incident.rdf_type

    #these will get stomped on by before_save, but they make it valid for now...
    self.label ||= "incident"
  end

  # get an instance of a place object, based on the uri in this incident's place predicate
  def place
    if @place
      @place
    elsif !self[Incident.place_predicate].empty?
      @place = Place.find(self[Incident.place_predicate].first)
    else
      nil
    end
  end

  # make an association to a place by passing in a place object.
  def place=(new_place)
    @place = new_place
    self[Incident.place_predicate] = new_place.uri
  end

  # get an instance of a interval object, based on the uri in this incident's interval predicate
  def interval
    if @interval
      @interval
    elsif !self[Incident.interval_predicate].empty?
      @interval = Interval.find(self[Incident.interval_predicate].first)
    else
      nil
    end
  end

  # make an association to a interval by passing in a interval object.
  def interval=(new_interval)
    @interval = new_interval
    self[Incident.interval_predicate] = new_interval.uri
  end

  def self.all
    query = "
      SELECT ?uri (<#{Incident.graph_uri}> AS ?graph)
      WHERE {
        GRAPH <#{Incident.graph_uri}> {
          ?uri a <#{Incident.rdf_type}> .
        }
      }"
    self.where(query)
  end

  private

  def before_save
    Rails.logger.debug "in incident before save"
    self.label = "Incident at "
    self.label += "[#{self.place.latitude.to_s}, #{self.place.longitude.to_s}]"
    self.label += ", begins: #{I18n.l(Time.parse(self.interval.begins_at), :format => :long)}" rescue nil
    self.label += ", ends:  #{I18n.l(Time.parse(self.interval.ends_at), :format => :long)}" if self.interval.ends_at rescue nil
  end


end