# Configure Rails Environment
ENV["RAILS_ENV"] = "test"
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'capybara/rails'
require 'capybara/dsl'
require 'webmock/rspec'

Rails.backtrace_cleaner.remove_silencers!

# Load support files
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

# By default, we want to allow connections to the local sparql server
WebMock.allow_net_connect!

Capybara.configure do |config|
  config.default_host = 'http://opendatacommunities.org'
end

RSpec.configure do |config|
  config.mock_with :rspec

  config.include PublishMyData::Engine.routes.url_helpers

  DatabaseCleaner.strategy = :truncation
  DatabaseCleaner.orm = "mongoid"

  config.before(:each) do

    Tripod::SparqlClient::Update.update('
      # delete from default graph:
      DELETE {?s ?p ?o} WHERE {?s ?p ?o};
      # delete from named graphs:
      DELETE {graph ?g {?s ?p ?o}} WHERE {graph ?g {?s ?p ?o}};
    ')

    # seed data
    FactoryGirl.create(:zone)
    FactoryGirl.create(:report_type)

    # clean mongo
    DatabaseCleaner.clean

    config.include Devise::TestHelpers, :type => :controller
  end

  config.before(:all, :type => :request) do
    host! 'pmd.local'
  end

end

PublishMyData.configure do |config|
  config.sparql_endpoint = 'http://127.0.0.1:3030/pmdtest/sparql'
  config.local_domain = 'pmd.local'
  config.maintenance_mode = false
end

def create_dummy_seed_data
   # make some reportTypes
  t1 = ReportType.new('http://reporttype1')
  t1.label = 'foo'
  t1[RDF.type] = ReportType.rdf_type
  t1.save!

  t2 = ReportType.new('http://reporttype2')
  t2.label = 'foo'
  t2[RDF.type] = ReportType.rdf_type
  t2.save!

  # make some zones
  z1 = Zone.new('http://zone1')
  z1.label = 'foo'
  z1[RDF.type] = Zone.rdf_type
  z1.save!

  z2 = Zone.new('http://zone2')
  z2.label = 'bar'
  z2[RDF.type] = Zone.rdf_type
  z2.save!
end