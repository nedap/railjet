require "bundler/gem_tasks"

# RSpec rake tasks
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)
task :default => :spec

# Gemfury rake tasks
require 'gemfury/tasks'
require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "railjet"
  gem.homepage = "https://github.com/nedap/railjet"
  gem.summary = "Railjet, Design patterns for Ruby on Rails"
  gem.email = "krzysztof.zalewski@nedap.com"
  gem.authors = ["Krzysztof Zalewski"]
  # dependencies defined in Gemfile
end

Gemfury.account = "nedap-healthcare"
task :release => 'fury:release'
