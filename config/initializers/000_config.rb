# APP_CONFIG = YAML.load_file(Rails.root + 'config/pmd.yml')[Rails.env]

# PublishMyData.configure do |config|
#   config.sparql_endpoint = APP_CONFIG['sparql_endpoint']
#   config.local_domain = APP_CONFIG['local_domain']
#   config.sparql_timeout_seconds = APP_CONFIG['sparql_timeout_seconds']
#   config.cache_sparql_results = APP_CONFIG['cache_sparql_results']
#   config.record_analytics = APP_CONFIG['record_analytics']
# end

# PmdAnalyticsModels.configure do |config|
#   config.log_level = Logger::DEBUG
#   config.log_file = "#{Rails.root}/log/analytics.log"
# end