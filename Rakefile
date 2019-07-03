# frozen_string_literal: true

# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.
require 'vault_api'
# This task  will be upload all *.yml files from config folder to vault
desc ' upload all *.yml files from config folder to vault'
task :upload, [:config_folder_path] do |_t, args|
  VaultApi::Config.upload(args.config_folder_path)
end
require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task default: :spec
