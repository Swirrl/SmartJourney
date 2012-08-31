FactoryGirl.define do
  factory :zone do
    label 'zone'
    rdf_type Zone.rdf_type

    initialize_with { new("http://zone1") }
  end
end
