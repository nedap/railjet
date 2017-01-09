require "railjet/repository/active_record"
require "railjet/repository/cupido"

module Railjet
  module Repository
    extend  ::ActiveSupport::Concern

    attr_reader :registry
    delegate    :settings, to: :registry

    def initialize(registry, sources = {})
      @registry = registry
      @sources  = sources
    end

    private

    def record
      if defined?(record_repository_class)
        @record ||= record_repository_class.new(
          registry, 
          @sources[:record]
        )
      end
    end

    def cupido
      if defined?(cupido_repository_class)
        @cupido ||= cupido_repository_class.new(
          registry,
          @sources[:cupido]
        )
      end
    end

    def record_repository_class
      self.class::ActiveRecordRepository
    end

    def cupido_repository_class
      self.class::CupidoRepository
    end
  end
end
