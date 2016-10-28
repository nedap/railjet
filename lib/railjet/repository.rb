require "railjet/repository/active_record_repository"
require "railjet/repository/cupido_repository"

module Railjet
  module Repository
    extend  ::ActiveSupport::Concern

    attr_reader :registry
    delegate    :settings, to: :registry

    def initialize(registry, **kwargs)
      @registry = registry
      define_accessors(kwargs)
    end

    private

    def define_accessors(kwargs)
      kwargs.each do |name, val|
        repository_module.send(:define_method, name) { val }
        repository_module.send(:private, name)
      end
    end

    def repository_module
      @repository_module ||= Module.new.tap { |m| self.class.include(m) }
    end
  end
end
