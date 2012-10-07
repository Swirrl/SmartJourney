FactoryGirl.define do

  factory :report do
    label 'foobar'
    description 'foobar'
    created_at Date.new(2011,1,1)
    latitude 2.1
    longitude 53.1
    zone FactoryGirl.build(:zone)
    report_type_uri FactoryGirl.build(:report_type).uri
  end

end
