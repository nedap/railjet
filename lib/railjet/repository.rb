require "railjet/repository/active_record"
require "railjet/repository/cupido"

module Railjet
  module Repository
    extend  ::ActiveSupport::Concern

    attr_reader :registry
    delegate    :settings, to: :registry

    attr_reader :record_dao, :cupido_dao

    def initialize(registry, record: nil, cupido: nil)
      @registry = registry
      
      @record_dao  = record
      @cupido_dao  = cupido
    end

    private

    def record
      if defined?(record_repo)
        @record ||= record_repo.new(registry, record_dao)
      end
    end

    def cupido
      if defined?(cupido_repo)
        @cupido ||= cupido_repo.new(registry, cupido_dao)
      end
    end

    def record_repo
      self.class::ActiveRecordRepository
    end

    def cupido_repo
      self.class::CupidoRepository
    end
  end
end
