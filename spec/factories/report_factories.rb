FactoryGirl.define do

  factory :report do
    description 'foobar'
    datetime Date.new(2011,1,1)
    latitude 2.1
    longitude 53.1
    zone FactoryGirl.build(:zone)
    report_type FactoryGirl.build(:report_type)
    rdf_type Report.rdf_type
  end

end
