class Zone

  include Tripod::Resource

  def self.rdf_type
    RDF::URI("http://data.smartjourney.co.uk/def/Zone")
  end

  def self.graph_uri
    RDF::URI("http://data.smartjourney.co.uk/graph/zones")
  end

  field :label, RDF.label
  field :rdf_type, RDF.type
  field :notation, RDF::URI.new('http://www.w3.org/2004/02/skos/core#notation')


  #######################
  # NOTE:
  # The zones will be predefined in the database, do don't need a initializer or validations
  #######################

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
    #TODO.
  end

  def extent_json_url
    "http://data.smartjourney.co.uk/zone_boundaries/#{notation}.json"
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

end