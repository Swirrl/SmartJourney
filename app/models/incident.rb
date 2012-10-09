class Incident

  include Tripod::Resource

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

   # override initialise
  def initialize(uri=nil, graph_uri=nil)
    super(uri || RDF::URI("http://data.smartjourney.co.uk/id/incident/#{Guid.new.to_s}"), graph_uri || Incident.graph_uri)
    self.rdf_type ||= Incident.rdf_type
    self.label ||= "an incident" #TODO: auto gen based on contents, before_save
  end

  # get an instance of a place object, based on the uri in this incident's place predicate
  def place
    unless self[Incident.place_predicate].empty?
      Incident.find(self[Incident.place_predicate].first)
    else
      nil
    end
  end

  # make an association to a place by passing in a place object.
  def place=(new_place)
    self[Incident.place_predicate] = new_place.uri
  end

  # get an instance of a interval object, based on the uri in this incident's interval predicate
  def interval
    unless self[Incident.interval_predicate].empty?
      Incident.find(self[Incident.interval_predicate].first)
    else
      nil
    end
  end

  # make an association to a interval by passing in a interval object.
  def interval=(new_interval)
    self[Incident.interval_predicate] = new_interval.uri
  end

  def self.delete_all
    Tripod::SparqlClient::Update::update(
      "DELETE {graph <#{Incident.graph_uri}> {?s ?p ?o}}
      WHERE {graph <#{Incident.graph_uri}> {?s ?p ?o}}"
    )
  end

end