require_relative "generic"

module Railjet
  module Repository
    class Cupido < Generic
      def build(args = {})
        cupido.new(args)
      end

      def persist(object)
        cupido.do.create(object)
      end

      private

      def for_person(person)
        cupido.find.proxy(person.external_id)
      end

      def cupido_class(obj)
        "Cupido::#{obj.class.name}".constantize
      end
    end
  end
end
