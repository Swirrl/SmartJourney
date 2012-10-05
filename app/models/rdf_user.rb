# model to allow persistence to the triple of the public user info
class RdfUser

  include Tripod::Resource

  field :label, RDF::RDFS.label
  field :rdf_type, RDF.type

  def initialize(uri=nil, graph_uri=nil)
    super(uri, graph_uri || RdfUser.graph_uri)
    self.rdf_type ||= RdfUser.rdf_type
  end

  def self.graph_uri
    RDF::URI("http://#{PublishMyData.local_domain}/graph/users")
  end

  def self.rdf_type
    RDF::URI("http://rdfs.org/sioc/ns#UserAccount")
  end

end