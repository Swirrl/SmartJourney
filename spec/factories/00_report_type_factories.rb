FactoryGirl.define do
  factory :report_type do
    label 'report type'
    initialize_with { new('http://reporttype1') }
  end
end