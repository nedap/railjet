module Railjet
  module Repository
    class Registry
      attr_reader :repositories

      def initialize
        @repositories             = {}
        @initialized_repositories = {}
      end

      def register(name, repository, **kwargs)
        add_to_registry(name, repository, kwargs)
        define_accessor(name)
      end

      def new(**kwargs)
        self.clone.tap do |registry|
          clone_module = Module.new.tap { |m| registry.extend(m) }

          kwargs.each do |name, val|
            clone_module.send(:define_method, name) { val }
          end
        end
      end

      private

      def add_to_registry(name, repository, args = {})
        @repositories.merge!(name => {
          repository: repository,
          args:       args
        })
      end

      def get_from_registry(name)
        @repositories[name]
      end

      def initialize_repo(name)
        @initialized_repositories[name] ||= begin
          repo = get_from_registry(name)
          repo[:repository].new(self, **repo[:args])
        end
      end

      def define_accessor(name)
        pluralized_name = name.to_s.pluralize
        registry_module.send(:define_method, pluralized_name) { initialize_repo(name) }
      end

      def registry_module
        @registry_module ||= Module.new.tap { |m| self.class.include(m) }
      end
    end
  end
end