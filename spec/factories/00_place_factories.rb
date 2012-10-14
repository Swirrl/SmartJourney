FactoryGirl.define do

  factory :place do
    latitude -2.10
    longitude 57.15
    zone Zone.new('http://data.smartjourney.co.uk/id/zone/aberdeenshire/laurencekirk')
  end

end
