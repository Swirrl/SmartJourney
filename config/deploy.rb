require 'bundler/capistrano' # enable bundler stuff!
load 'deploy/assets'

# rvm stuff
$:.unshift(File.expand_path('./lib', ENV['rvm_path'])) # Add RVM's lib directory to the load path.
require "rvm/capistrano"                  # Load RVM's capistrano plugin.
set :rvm_ruby_string, '1.9.3-p194'        # Or whatever env you want it to run in.
set :rvm_type, :user
###

set :application, "pmd_winter"

server "176.9.106.113", :app, :web, :db, :primary => true

set(:deploy_to) { File.join("", "home", user, "sites", application) }
set :config_files, %w(pmd.yml)

default_run_options[:pty] = true

ssh_options[:keys] = [File.join(ENV["HOME"], ".ssh", "id_rsa")]

set :repository,  "git@github.com:Swirrl/pmd_winter.git"
set :scm, "git"
set :ssh_options, {:forward_agent => true, :keys => "~/.ssh/id_rsa" }
set :user, "rails"
set :runner, "rails"
set :admin_runner, "rails"
set :use_sudo, false

set :branch, "ric-restyle"

set :deploy_via, :remote_cache

after "deploy:setup", "deploy:upload_app_config"
after "deploy:finalize_update", "deploy:symlink_app_config", "deploy:symlink_zone_boundaries"

namespace :deploy do

  desc <<-DESC
    overriding deploy:cold task to not migrate...
  DESC
  task :cold do
    update
    start
  end

  desc <<-DESC
    overriding start to just call restart
  DESC
  task :start do
    restart
  end

  desc <<-DESC
    overriding stop to do nothing - you cant stop a passenger app!
  DESC
  task :stop do
  end

  desc <<-DESC
    overriding start to just touch the restart txt
  DESC
  task :restart do
    run "touch #{current_path}/tmp/restart.txt"
    sudo "echo 'flush_all' | nc localhost 11211" # flush memcached
  end

  desc "Copy local config files from app's config folder to shared_path."
  task :upload_app_config do
    config_files.each { |filename| put(File.read("config/#{filename}"), "#{shared_path}/#{filename}", :mode => 0640) }
  end

  desc "Symlink the application's config files specified in :config_files to the latest release"
  task :symlink_app_config do
    config_files.each { |filename| run "ln -nfs #{shared_path}/#{filename} #{latest_release}/config/#{filename}" }
  end

  desc "Symlink zone boundaries"
  task :symlink_zone_boundaries do
    run "ln -nfs /home/rails/aberdeen-data/boundaries #{latest_release}/public/zone_boundaries"
  end

end

require './config/boot'
require 'airbrake/capistrano'
