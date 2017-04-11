require "bundler/gem_tasks"

# RSpec rake tasks
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)
task :default => :spec

# Version rake tasks
require 'rake-version'

RakeVersion::Tasks.new do |v|
  v.copy 'lib/railjet/version.rb'
end

# Rubygems rake tasks
require "bundler/gem_tasks"
