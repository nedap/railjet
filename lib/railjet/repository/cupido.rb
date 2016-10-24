module Railjet
  module Repository
    module Cupido
      extend ::ActiveSupport::Concern

      included do
        attr_reader :registry, :cupido
      end

      def initialize(registry, cupido)
        @registry = registry
        @cupido   = cupido
      end

      def build(args = {})
        cupido.new(args)
      end

      def persist(object)
        cupido.do.create(object)
      end

      private

      def cupido_class(obj)
        "Cupido::#{obj.class.name}".constantize
      end
    end
  end
end
