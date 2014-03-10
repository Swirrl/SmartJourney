PmdWinter::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_assets = false

  # Compress JavaScripts and CSS
  config.assets.compress = false
  config.assets.css_compressor = :yui # this requires java on the server. sudo apt-get install openjdk-6-jre
  config.assets.js_compressor = :yui

  # DO fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = true #fall back for leaflet marker cluster etc.

  # Generate digests for assets URLs
  config.assets.digest = false

  # Defaults to nil and saved in location specified by config.assets.prefix
  # config.assets.manifest = YOUR_PATH

  # Specifies the header that your server uses for sending files
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # See everything in the log (default is :info)
  # config.log_level = :debug

  # Prepend all log lines with the following tags
  # config.log_tags = [ :subdomain, :uuid ]

  # Use a different logger for distributed setups
  # config.logger = ActiveSupport::TaggedLogging.new(SyslogLogger.new)

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  # Enable serving of images, stylesheets, and JavaScripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
  # config.assets.precompile += %w( search.js )

  config.assets.precompile += %w( data.js )
  config.assets.precompile += %w( data.css )

  config.action_mailer.default_url_options = { :host => "smartjourney.co.uk" }


  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  # configure any settings for testing...
  Tripod.configure do |config|
    #TODO! change!
    config.update_endpoint = 'http://46.4.78.148/winter/update'
    config.query_endpoint = 'http://46.4.78.148/winter/sparql'
  end

  # NOTE: on 11212 on production
  config.cache_store = :dalli_store, 'localhost:11212', {:compress => true, :compress_threshold => 64*1024, :namespace => 'pmd_winter' }

end
