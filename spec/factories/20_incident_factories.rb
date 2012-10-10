FactoryGirl.define do

  factory :incident do
    place FactoryGirl.build(:place)
    interval FactoryGirl.build(:interval)
    description "hell freezing over"
  end

end
