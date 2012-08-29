class Zone

  include Tripod::Resource

  field :label, RDF.label
  validates :label, :presence => true

  # override initialise
  def initialize(uri=nil, graph_uri=nil)
    super(uri, graph_uri || Zone.graph_uri)
  end

  def self.all
    Report.where("
      SELECT ?uri (<#{Zone.graph_uri}> AS ?graph)
      WHERE {
        GRAPH <#{Zone.graph_uri}> {
          ?uri a <#{Zone.rdf_type.to_s}> .
        }
      }"
    )
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
    # there will probably be a boundary resource, with the boundary as geojson.

    # for now, return the first zone, if there are any!
    unless self.all.empty?
      self.all.first
    else
      nil
    end
  end

  def self.graph_uri
    RDF::URI("http://#{PublishMyData.local_domain}/graph/zones")
  end

  def self.rdf_type
    RDF::URI("http://#{PublishMyData.local_domain}/zones")
  end

end