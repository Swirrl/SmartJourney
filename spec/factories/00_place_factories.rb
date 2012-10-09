FactoryGirl.define do

  factory :place do
    latitude 2.1
    longitude 53.1
    zone Zone.new('http://data.smartjourney.co.uk/id/zone/aberdeenshire/laurencekirk')
  end

end
