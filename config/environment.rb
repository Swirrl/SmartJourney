# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
PmdWinter::Application.initialize!

if defined?(PhusionPassenger)
  PhusionPassenger.on_event(:starting_worker_process) do |forked|
    # Only works with DalliStore
    if forked
      Rails.cache.reset
      # PublishMyData::Analytics::ActionLog.revive_thread
      # PublishMyData::Analytics::SparqlLog.revive_thread
    end
  end
end
