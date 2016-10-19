module Railjet
  module Repository
    class Registry
      attr_reader :repositories

      def initialize
        @repositories = {}
      end

      def register(name, repository, **kwargs)
        add_repo_to_registry(name, repository, kwargs)
        define_repo_accessor(name)
      end

      def initialize_copy(original)
        super
        @repositories = @repositories.dup
      end

      def new(**kwargs)
        self.clone.tap do |registry|
          kwargs.each do |name, val|
            ivar_name = "@#{name}"

            registry.instance_variable_set(ivar_name, val)
            registry.define_singleton_method name do
              instance_variable_get(ivar_name)
            end
          end
        end
      end

      private

      def add_repo_to_registry(name, repository, args = {})
        @repositories.merge!(name => {
          repository: repository,
          args:       args
        })
      end

      def define_repo_accessor(name)
        pluralized_name = name.to_s.pluralize
        pluralized_ivar = "@#{pluralized_name}"

        define_singleton_method pluralized_name do
          if instance_variable_defined?(pluralized_ivar)
            instance_variable_get(pluralized_ivar)
          else
            instance_variable_set(pluralized_ivar, call_repo_accessor(name))
          end
        end
      end

      def call_repo_accessor(name)
        repo = @repositories[name]

        klass = repo[:repository]
        args  = repo[:args]

        klass.new(self, **args)
      end
    end
  end
end