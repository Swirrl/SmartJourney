# The report types will be predefined in the database.
class ReportType

  include Tripod::Resource

  field :label, RDF.label

  def self.graph_uri
    #TODO: fix.
    RDF::URI('http://reporttypes')
  end

  def initialize(uri=nil, graph_uri=nil)
    super(uri, graph_uri || ReportType.graph_uri)
  end

  def self.all
    #TODO: replace with results of a query.
    [ReportType.find('http://testreporttype')]
  end

end