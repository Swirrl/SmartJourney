FactoryGirl.define do

  factory :interval do
    begins_at Date.new(2011,1,1)
    ends_at Date.new(2011,1,2)
  end

end
