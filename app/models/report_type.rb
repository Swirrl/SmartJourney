class ReportType

  include Tripod::Resource

  field :label, RDF.label

  # override initialise
  def initialize(uri=nil, graph_uri=nil)
    super(uri, graph_uri || ReportType.graph_uri)
    self[RDF.type] = ReportType.rdf_type
  end

  def self.graph_uri
    RDF::URI("http://#{PublishMyData.local_domain}/graph/reporttypes")
  end

  def self.rdf_type
    RDF::URI("http://#{PublishMyData.local_domain}/reports")
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