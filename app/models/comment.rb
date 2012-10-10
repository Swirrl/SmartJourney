class Comment

  include Tripod::Resource

  def self.created_at_predicate
    RDF::URI('http://purl.org/dc/terms/created')
  end

  def self.creator_predicate
    RDF::URI('http://rdfs.org/sioc/ns#hasCreator')
  end

  def self.rdf_type
    RDF::URI("http://data.smartjourney.co.uk/def/Comment")
  end

  def self.graph_uri
    RDF::URI("http://data.smartjourney.co.uk/graph/reports") # goes in the reports graph
  end

  field :rdf_type, RDF.type
  field :label, RDF::RDFS.label
  field :content, RDF::URI("http://rdfs.org/sioc/ns#content")
  field :created_at, self.created_at_predicate.to_s, :datatype => RDF::XSD.dateTime

  validates :label, :rdf_type, :creator, :content, :presence => true

  # override initialise
  def initialize(uri=nil, graph_uri=nil)
    super(uri || RDF::URI("http://data.smartjourney.co.uk/id/place/#{Guid.new.to_s}"), graph_uri || Place.graph_uri)
    self.rdf_type ||= Place.rdf_type
    self.label ||= "a comment" #TODO: auto gen based on contents, before_save
    self.created_at ||= Time.now #TODO: do this before save instead
  end

  # returns a user object.
  def creator
    unless self[Comment.creator_predicate].empty?
      User.where(:uri => self[Comment.creator_predicate].first.to_s).first
    else
      nil
    end
  end

  # pass in an instance of a user object.
  def creator=(new_user)
    self[Comment.creator_predicate] = new_user.uri
  end

  def self.all
    query = "
      SELECT ?uri (<#{Comment.graph_uri}> AS ?graph)
      WHERE {
        GRAPH <#{Comment.graph_uri}> {
           ?uri a <#{Comment.rdf_type}> .
        }
      }"
    self.where(query)
  end


end