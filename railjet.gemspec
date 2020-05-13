# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "railjet/version"

Gem::Specification.new do |spec|
  spec.name          = "railjet"
  spec.version       = Railjet::VERSION
  spec.authors       = ["Krzysztof Zalewski"]
  spec.email         = ["zlw.zalewski@gmail.com"]

  spec.summary       = %q{Better architecture for high-speed railway}
  spec.description   = %q{Design patterns for Ruby on Rails}
  spec.homepage      = "https://github.com/nedap/railjet"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake",                 "> 13"
  spec.add_development_dependency "rspec",                "~> 3.0"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "rake-version",         "~> 1.0"

  spec.add_dependency             "activesupport",        '> 4'
  spec.add_dependency             "activemodel",          '> 4'
  spec.add_dependency             "virtus",               "~> 1.0.2"
  spec.add_dependency             "validates_timeliness", "~> 4.1"
end
