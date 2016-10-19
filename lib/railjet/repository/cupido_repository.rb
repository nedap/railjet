module Railjet
  module Repository
    module CupidoRepository
      extend ::ActiveSupport::Concern

      def shape(args = {})
        cupido.new(args)
      end

      def push(object)
        cupido.do.create(object)
      end

      private

      def cupido_class(obj)
        "Cupido::#{obj.class.name}".constantize
      end
    end
  end
end
