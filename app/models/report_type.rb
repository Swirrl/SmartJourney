class ReportType

  include Tripod::Resource

  field :label, RDF.label
  validates :label, :presence => true

  # override initialise
  def initialize(uri=nil, graph_uri=nil)
    super(uri, graph_uri || ReportType.graph_uri)
  end

  def self.graph_uri
    RDF::URI("http://#{PublishMyData.local_domain}/graph/reporttypes")
  end

  def self.rdf_type
    RDF::URI("http://#{PublishMyData.local_domain}/reportstypes")
  end

  def self.all
    query = "
      SELECT ?report_type (<#{ReportType.graph_uri}> AS ?graph)
      WHERE {
        GRAPH <#{ReportType.graph_uri}> {
          ?report_type a <#{ReportType.rdf_type.to_s}> .
        }
      }"
    self.where(query, :uri_variable => 'report_type')
  end

end