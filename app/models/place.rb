class Place

  include Tripod::Resource
  include BeforeSave
  include ActiveModel::Validations::Callbacks

  def self.zone_predicate
    RDF::URI("http://data.smartjourney.co.uk/def/zone")
  end

  def self.rdf_type
    RDF::URI("http://www.w3.org/2003/01/geo/wgs84_pos#SpatialThing")
  end

  def self.graph_uri
    RDF::URI("http://data.smartjourney.co.uk/graph/reports") # goes in the reports graph
  end

  field :latitude, 'http://www.w3.org/2003/01/geo/wgs84_pos#lat', :datatype => RDF::XSD.decimal
  field :longitude, 'http://www.w3.org/2003/01/geo/wgs84_pos#long', :datatype => RDF::XSD.decimal
  field :rdf_type, RDF.type
  field :label, RDF::RDFS.label

  validates :latitude, :longitude, :format => { :with => %r([0-9]+\.[0-9]*) }, :if => Proc.new {|p| (p.latitude.present? && p.longitude.present?) }
  validates :label, :rdf_type, :longitude, :latitude, :zone, :presence => true

  before_validation :set_label
  before_validation :associate_zone

   # override initialise
  def initialize(uri=nil, graph_uri=nil)
    super(uri || RDF::URI("http://data.smartjourney.co.uk/id/place/#{Guid.new.to_s}"), graph_uri || Place.graph_uri)
    self.rdf_type ||= Place.rdf_type
  end

  # get an instance of a zone object, based on the uri in this report's zone predicate
  def zone
    if @zone
      @zone
    elsif !self[Place.zone_predicate].empty?
      @zone = Zone.find(self[Place.zone_predicate].first)
    else
      nil
    end
  end

  # make an association to a zone by passing in a zone object.
  # TODO: this pattern of deleting a triple should for a predicate should be moved into tripod.
  def zone=(new_zone)
    @zone = new_zone
    if new_zone
      self[Place.zone_predicate] = new_zone.uri
    else
      Rails.logger.debug "deleting zone"
      # delete the zone statement.
      self.repository.query( [:subject, RDF::URI.new(Place.zone_predicate), :object] ) do |statement|
        self.repository.delete(statement)
      end
    end
  end

  # associates this report with a single zone, based on this report's lat-longs
  def associate_zone
    Rails.logger.debug("associating zone")
    z = Zone.zone_for_lat_long(self.latitude, self.latitude)
    self.zone = z
  end

  def self.all
    query = "
      SELECT ?uri (<#{Place.graph_uri}> AS ?graph)
      WHERE {
        GRAPH <#{Place.graph_uri}> {
          ?uri a <#{Place.rdf_type}> .
        }
      }"
    self.where(query)
  end

  private

  def set_label
    self.label = self.latitude.to_s + ', ' + self.longitude.to_s
  end

end