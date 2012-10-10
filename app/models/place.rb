class Place

  include Tripod::Resource

  def self.zone_predicate
    RDF::URI("http://data.smartjourney.co.uk/def/zone")
  end

  def self.rdf_type
    RDF::URI("http://www.w3.org/2003/01/geo/wgs84_pos#spatialThing")
  end

  def self.graph_uri
    RDF::URI("http://data.smartjourney.co.uk/graph/reports") # goes in the reports graph
  end

  field :latitude, 'http://www.w3.org/2003/01/geo/wgs84_pos#lat', :datatype => RDF::XSD.decimal
  field :longitude, 'http://www.w3.org/2003/01/geo/wgs84_pos#long', :datatype => RDF::XSD.decimal
  field :rdf_type, RDF.type
  field :label, RDF::RDFS.label

  validates :latitude, :longitude, :format => { :with => %r([0-9]+\.[0-9]*) }, :if => Proc.new {|p| (p.latitude.present? && p.longitude.present?) }
  validates :label, :rdf_type, :longitude, :latitude, :presence => true

   # override initialise
  def initialize(uri=nil, graph_uri=nil)
    super(uri || RDF::URI("http://data.smartjourney.co.uk/id/place/#{Guid.new.to_s}"), graph_uri || Place.graph_uri)
    self.rdf_type ||= Place.rdf_type
    self.label ||= "a place" #TODO: auto gen based on contents, before_save
  end

  # get an instance of a zone object, based on the uri in this report's zone predicate
  def zone
    if @zone
      @zone
    elsif !self[Place.zone_predicate].empty?
      Zone.find(self[Place.zone_predicate].first)
    else
      nil
    end
  end

  # make an association to a zone by passing in a zone object.
  def zone=(new_zone)
    @zone = new_zone
    self[Place.zone_predicate] = new_zone.uri
  end

  # associates this report with a single zone, based on this report's lat-longs.
  # TODO: call this before every save time? Use callbacks? (need to add to tripod).
  def associate_zone
    z = Zone.zone_for_lat_long(self.latitude, self.latitude)
    self.zone = z if z
  end

  def self.all
    query = "
      SELECT ?uri (<#{Place.graph_uri}> AS ?graph)
      WHERE {
        GRAPH <#{Place.graph_uri}> {
          ?uri ?p ?o .
        }
      }"
    self.where(query)
  end

  def self.delete_all
    Tripod::SparqlClient::Update::update(
      "DELETE {graph <#{Place.graph_uri}> {?s ?p ?o}}
      WHERE {graph <#{Place.graph_uri}> {?s ?p ?o}}"
    )
  end

end