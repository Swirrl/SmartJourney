source 'http://rubygems.org'

gem 'rails', '3.2.11'

# these gems aren't required unless you also want to run a Linked Data site:

#gem 'publish_my_data', :git => 'git@github.com:Swirrl/pmd_core.git', :branch => 'master' # this is the rails 3.2 engine version.

# uncomment to use local version of pmd_core.
#gem 'publish_my_data', :path => '../pmd_core'

# as this comes from github, we need to respecify it again, or bundler complains.
#gem 'pmd_analytics_models', '~>0.0.4', git: 'git@github.com:Swirrl/pmd_analytics_models.git', branch: 'master'

# uncomment to use local version of analytics models.
#gem 'pmd_analytics_models',  :path => '../pmd_analytics_models'

gem 'tripod', '0.0.10'
# uncomment to use a local version of tripod
#gem 'tripod', :path => '../tripod'

gem 'rails_autolink'
gem 'devise', '~> 2.1'
gem 'cancan'
gem 'dynamic_form'
gem 'mongoid', '~>3.0.0'
gem 'guid'
gem 'airbrake'
gem 'haml-rails' # used for docs
gem 'jquery-rails'
gem 'mixable_engines' # allows overriding of individual controller actions: http://stackoverflow.com/questions/5045068/extending-controllers-of-a-rails-3-engine-in-the-main-app
gem 'rdiscount'
gem 'sass-rails'
gem 'honeypot-captcha'

# for delayed job...
gem 'delayed_job_mongoid'
gem 'daemons'

group :assets do
  gem 'yui-compressor' #requires java
end

group :production do
  gem 'dalli', '>= 1.0.0'
end

group :test, :development do
  gem "factory_girl_rails", "~> 4.0"
  gem "rspec-rails", "~> 2.0"
  gem 'capybara'
  gem 'ZenTest'
  gem 'autotest-rails'
  gem 'autotest-fsevent'
  gem 'autotest-growl'
  gem 'capistrano'
  gem 'database_cleaner'
end

group :test do
  gem "webmock"
end
