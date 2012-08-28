class Zone

  include Tripod::Resource

  field :boundary_points, 'http://boundary-point', :multivalued => true

  # override initialise
  def initialize(uri=nil, graph_uri=nil)
    super(uri, graph_uri || Zone.graph_uri)
    self[RDF.type] = Zone.rdf_type
  end

  # get an array of this zone's reports.
  def reports
    Report.where("
      SELECT ?report (<#{Report.graph_uri}> AS ?graph)
      WHERE {
        GRAPH <#{Report.graph_uri}> {
          ?report <#{Report.zone_predicate.to_s}> <#{self.uri.to_s}> .
          ?report a <#{Report.rdf_type.to_s}> .
        }
      }",
      :uri_variable => 'report'
    )
  end

  def self.zone_for_lat_long(lat, long)
    # TODO: return the zone that contains this lat/long, based on the boundary points
  end

  def self.graph_uri
    RDF::URI("http://#{PublishMyData.local_domain}/graph/zones")
  end

end