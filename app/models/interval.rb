class Interval

  include Tripod::Resource
  include BeforeSave

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

  # override initialise
  def initialize(uri=nil, graph_uri=nil)
    super(uri || RDF::URI("http://data.smartjourney.co.uk/id/interval/#{Guid.new.to_s}"), graph_uri || Interval.graph_uri)
    self.rdf_type ||= Interval.rdf_type

    #these will get stomped on by before_save, but they make it valid for now...
    self.label ||= "interval"
    self.begins_at ||= Time.now
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

  def before_save
    self.label = "begins: #{I18n.l(Time.parse(self.begins_at), :format => :long)}"
    self.label += ", ends:  #{I18n.l(Time.parse(self.ends_at), :format => :long)}" if self.ends_at
  end

end