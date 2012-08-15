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

  config.before(:each) do
    PublishMyData.configure do |config|
      config.sparql_endpoint = 'http://127.0.0.1:3030/pmdtest/sparql'
      config.local_domain = 'pmd.local'
      config.maintenance_mode = false
    end
  end

  config.before(:all, :type => :request) do
    host! 'pmd.local'
  end

end