FactoryGirl.define do
  factory :report_type do
    label 'report type'
    rdf_type ReportType.rdf_type

    initialize_with { new('http://reporttype1') }
  end
end