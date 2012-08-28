class Report

  include Tripod::Resource

  field :description, 'http://description'
  field :rdf_type, RDF.type
  field :datetime, 'http://datetime', :datatype => RDF::XSD.datetime
  field :latitude, 'http://lat', :datatype => RDF::XSD.double
  field :longitude, 'http://long', :datatype => RDF::XSD.double

  validates :datetime, :latitude, :longitude, :presence => true
  validates :latitude, :longitude, :format => { :with => %r([0-9]+\.[0-9]*) }
  validate :check_format_of_datetime

  #override innitialise
  def initialize(uri=nil, graph_uri=nil)
    super(uri || Report.generate_unique_uri, graph_uri || Report.graph_uri)
    self.rdf_type = Report.rdf_type
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

  protected

  def check_format_of_datetime
    begin
      DateTime.parse(self.datetime)
    rescue
      errors.add(:datetime, "not a valid format")
    end
  end
end