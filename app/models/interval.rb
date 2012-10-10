class Interval

  include Tripod::Resource

  def self.rdf_type
    RDF::URI("http://purl.org/NET/c4dm/timeline.owl#Interval")
  end

  def self.graph_uri
    RDF::URI("http://data.smartjourney.co.uk/graph/reports") # goes in the reports graph
  end

  field :begins_at, 'http://purl.org/NET/c4dm/timeline.owl#beginsAtDateTime', :datatype => RDF::XSD.dateTime
  field :ends_at, 'http://purl.org/NET/c4dm/timeline.owl#endsAtDateTime', :datatype => RDF::XSD.dateTime
  field :rdf_type, RDF.type
  field :label, RDF::RDFS.label

  validates :label, :rdf_type, :presence => true

  # override initialise
  def initialize(uri=nil, graph_uri=nil)
    super(uri || RDF::URI("http://data.smartjourney.co.uk/id/interval/#{Guid.new.to_s}"), graph_uri || Interval.graph_uri)
    self.rdf_type ||= Interval.rdf_type
    self.label ||= "an interval" #TODO: auto gen based on contents, before_save
  end

   def self.all
    query = "
      SELECT ?uri (<#{Interval.graph_uri}> AS ?graph)
      WHERE {
        GRAPH <#{Interval.graph_uri}> {
          ?uri ?p ?o .
        }
      }"
    self.where(query)
  end

  def self.delete_all
    Tripod::SparqlClient::Update::update(
      "DELETE {graph <#{Interval.graph_uri}> {?s ?p ?o}}
      WHERE {graph <#{Interval.graph_uri}> {?s ?p ?o}}"
    )
  end

end