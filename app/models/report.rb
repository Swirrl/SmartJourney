class Report

  include Tripod::Resource

  extend ActiveModel::Callbacks

  field :description, 'http://description'
  field :datetime, 'http://datetime', :datatype => RDF::XSD.datetime
  field :latitude, 'http://lat', :datatype => RDF::XSD.double
  field :longitude, 'http://long', :datatype => RDF::XSD.double

  validates :datetime, :latitude, :longitude, :presence => true
  validates :latitude, :longitude, :format => { :with => %r([0-9]+\.[0-9]*) }
  validate :check_format_of_datetime

  # override innitialise
  def initialize(uri=nil, graph_uri=nil)
    super(uri || Report.generate_unique_uri, graph_uri || Report.graph_uri)
    self[RDF.type] = Report.rdf_type
  end

  # get an instance of a zone object, based on the uri in this report's zone predicate
  def zone
    unless self[Report.zone_predicate].empty?
      Zone.new(self[Report.zone_predicate], Zone.graph_uri)
    else
      nil
    end
  end

  # make an association to a zone by passing in a zone object.
  def zone=(zone)
    self['http://zone'] = zone.uri
  end

  def self.zone_predicate
    RDF::URI('http://zone')
  end

  def self.all
    query = "
      SELECT ?uri (<#{Report.graph_uri}> AS ?graph)
      WHERE {
        GRAPH <#{Report.graph_uri}> {
          ?uri ?p ?o .
          ?uri a <#{Report.rdf_type.to_s}> .
        }
      }"
    Report.where(query)
  end

  def self.generate_unique_uri
    g = Guid.new
    RDF::URI("http://#{PublishMyData.local_domain}/id/report/#{g.to_s}")
  end

  def self.graph_uri
    RDF::URI("http://#{PublishMyData.local_domain}/graph/reports")
  end

  def self.rdf_type
    RDF::URI("http://#{PublishMyData.local_domain}/reports")
  end

  # associates this report with a single zone, based on this report's lat-longs.
  # TODO: call this before every save time? Use callbacks? (need to add to tripod).
  def associate_zone
    self.zone = Zone.zone_for_lat_long(self.latitude.to_f, self.latitude.to_f)
  end

  protected

  def check_format_of_datetime
    begin
      DateTime.parse(self.datetime)
    rescue
      errors.add(:datetime, "not a valid format")
    end
  end
end