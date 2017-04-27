module Railjet
  module Repository
    class Generic < Module
      def self.[](**kwargs)
        type, dao = kwargs.first
        new(type, dao)
      end

      def initialize(type, dao)
        @type, @dao = type, dao
      end

      def included(klass)
        define_dao_accessor(@type, @dao)
        define_type_accessor(klass, @type)
        define_initializer(klass)
      end

      private

      def define_dao_accessor(type, dao)
        define_method type do
          @dao ||= dao.constantize
        end
      end

      def define_type_accessor(klass, type)
        klass.define_singleton_method(:type) do
          type
        end
      end

      def define_initializer(klass)
        klass.class_eval do
          attr_reader :registry

          def initialize(registry, dao: nil)
            @registry = registry
            @dao      = dao
          end
        end
      end
    end
  end
end