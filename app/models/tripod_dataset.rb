class TripodDataset

  include Tripod::Resource

  field :modified, RDF::URI("http://purl.org/dc/terms/modified"), :datatype => RDF::XSD.dateTime


end