require "railjet/repository/active_record"
require "railjet/repository/cupido"

module Railjet
  module Repository
    extend  ::ActiveSupport::Concern

    attr_reader :registry
    delegate    :settings, to: :registry

    def initialize(registry, **kwargs)
      @registry = registry
      define_accessors(**kwargs)

      initialize_record_repository if defined?(record_repository_class)
      initialize_cupido_repository if defined?(cupido_repository_class)
    end

    private

    def define_accessors(**kwargs)
      kwargs.each do |name, val|
        repository_module.send(:define_method, name) { val }
        repository_module.send(:protected, name)
      end
    end

    def repository_module
      @repository_module ||= Module.new.tap { |m| self.class.include(m) }
    end

    def initialize_record_repository
      if respond_to?(:record, true)
        def self.record
          @record ||= record_repository_class.new(registry, super)
        end
      else
        def self.record
          @record ||= record_repository_class.new(registry)
        end
      end
    end

    def record_repository_class
      self.class::ActiveRecordRepository
    end

    def initialize_cupido_repository
      if respond_to?(:cupido, true)
        def self.cupido
          @cupido ||= cupido_repository_class.new(registry, super)
        end
      else
        def self.cupido
          @cupido ||= cupido_repository_class.new(registry)
        end
      end
    end

    def cupido_repository_class
      self.class::CupidoRepository
    end
  end
end
