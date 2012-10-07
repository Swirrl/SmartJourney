class Zone


# For zones, going to use name slugs to identify them, as in the above http://data.smartjourney.co.uk/id/zone/inverurie
# I'll have boundary files called inverurie.json
# Will also have some RDF
# <http://data.smartjourney.co.uk/id/zone/inverurie> a <http://data.smartjourney.co.uk/def/Zone> ;
# <http://www.w3.org/2000/01/rdf-schema#label> "Inverurie" ;
# <http://www.w3.org/2004/02/skos/core#notation> "inverurie" ;
# <http://data.ordnancesurvey.co.uk/ontology/geometry/extent> <http://data.smartjourney.co.uk/id/zone/inverurie/geometry> .
# Then use the 'geometry' URI to link to the actual boundary file - so you can find boundary files via RDF, though in the app, we'd prob just hack our way to the
# right file name. But could use the skos:notation property to find the slug by RDF if necessary

# <http://data.smartjourney.co.uk/id/zone/inverurie/geometry>
# <http://data.ordnancesurvey.co.uk/ontology/geometry/asGeoJSON> <http://data.smartjourney.co.uk/zone_boundaries/inverurie.json> .

  include Tripod::Resource

  field :label, RDF.label
  field :rdf_type, RDF.type
  field :notation, RDF::URI.new('http://www.w3.org/2004/02/skos/core#notation')

  validates :label, :presence => true
  validates :rdf_type, :presence => true


  # override initialise
  def initialize(uri=nil, graph_uri=nil)
    super(uri, graph_uri || Zone.graph_uri)
    self.rdf_type ||= Zone.rdf_type if uri
  end

  def self.all
    self.where("
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