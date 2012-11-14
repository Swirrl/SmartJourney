# model to allow persistence to the triple of the public user info
class RdfUser

  include Tripod::Resource

  def self.graph_uri
    RDF::URI("http://data.smartjourney.co.uk/graph/users")
  end

  def self.rdf_type
    RDF::URI("http://rdfs.org/sioc/ns#UserAccount")
  end

  field :label, RDF::RDFS.label
  field :rdf_type, RDF.type

  validates :label, :rdf_type, :presence => true

  def initialize(uri=nil, graph_uri=nil)
    super(uri, graph_uri || RdfUser.graph_uri)
    self.rdf_type ||= RdfUser.rdf_type
  end

  def self.delete_all
    Tripod::SparqlClient::Update::update(
      "DELETE {graph <#{RdfUser.graph_uri}> {?s ?p ?o}}
      WHERE {graph <#{RdfUser.graph_uri}> {?s ?p ?o}}"
    )
  end


end