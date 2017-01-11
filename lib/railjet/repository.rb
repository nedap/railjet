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
      if self.class.const_defined?("ActiveRecordRepository")
        @record ||= self.class::ActiveRecordRepository.new(registry, record_dao)
      end
    end

    def cupido
      if self.class.const_defined?("CupidoRepository")
        @cupido ||= self.class::CupidoRepository.new(registry, cupido_dao)
      end
    end
  end
end
