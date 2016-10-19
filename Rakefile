require "bundler/gem_tasks"

# RSpec rake tasks
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)
task :default => :spec

# Gemfury rake tasks
require 'gemfury/tasks'

Gemfury.account = "nedap-healthcare"
task :release => 'fury:release'
