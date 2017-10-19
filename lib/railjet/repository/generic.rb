module Railjet
  module Repository
    class Generic < Module
      class << self
        def [](dao = nil)
          new(dao)
        end

        attr_accessor :type
      end

      def initialize(dao)
        @dao  = dao
        @type = self.class.type
      end

      def included(klass)
        define_dao_accessor(@type, @dao)
        define_type_accessor(klass, @type)
        define_initializer(klass)
        include_repository_methods(klass)
      end

      private

      def define_dao_accessor(type, dao)
        define_method type do
          instance_variable_get("@#{type}") || instance_variable_set("@#{type}", (dao.constantize if dao.respond_to?(:constantize)))
        end
      end

      def define_type_accessor(klass, type)
        klass.define_singleton_method(:type) { type }
      end

      def define_initializer(klass)
        klass.class_eval do
          attr_reader :registry

          def initialize(registry, **kwargs)
            @registry = registry
            instance_variable_set("@#{self.class.type}", kwargs.fetch(self.class.type, nil))

            # Let's check if DAO was set through registry or set when including inner repo mixin
            unless send(self.class.type)
              raise ArgumentError, "Your repository #{self.class} need a DAO. It can be set with inner-repo mixin  or through registry with `#{self.class.type}:` option"
            end
          end
        end
      end
      
      def include_repository_methods(klass)
        if defined?(self.class::RepositoryMethods)
          klass.send :include, self.class::RepositoryMethods
        end
      end
    end
  end
end