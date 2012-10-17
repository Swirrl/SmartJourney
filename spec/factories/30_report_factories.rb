FactoryGirl.define do

  factory :report do
    latitude '57.15'
    longitude '-2.1'
    description 'hello this is a very long label blah blah'
  end

  factory :invalid_report, class: Report do
    latitude '57.15'
    longitude '-2.1'
    description ''
  end

end
