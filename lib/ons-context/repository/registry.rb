module OnsContext
  module Repository
    class Registry
      attr_reader :settings, :repositories

      def initialize(settings = nil)
        @settings     = settings
        @repositories = {}
      end

      def register(name, repository, **kwargs)
        add_repo_to_registry(name, repository, kwargs)
        define_repo_accessor(name)
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