module Railjet
  module Repository
    class Registry      
      attr_reader :repositories, :initialized_repositories
      protected   :repositories, :initialized_repositories
      
      def initialize
        @repositories             = {}
        @initialized_repositories = {}
      end

      def register(name, repository, **kwargs)
        add_to_registry(name, repository, **kwargs)
        define_accessor(name)
      end

      def new(**kwargs)
        self.clone.tap do |registry|
          unless kwargs.blank?
            clone_module = Module.new.tap { |m| registry.extend(m) }

            kwargs.each do |name, val|
              clone_module.send(:define_method, name) { val }
            end
          end
        end
      end

      private
      
      class RegisteredRepository
        attr_reader :repository, :additional_arguments
        
        def initialize(repository, **kwargs)
          @repository           = repository
          @additional_arguments = kwargs
        end
        
        def initialize_repo(registry)
          repository.new(registry, **additional_arguments)
        end
      end

      def initialize_copy(original)
        super
        
        @initialized_repositories = original.initialized_repositories.dup
        @repositories             = original.repositories.dup
        @registry_module          = nil
      end

      def add_to_registry(name, repository, **kwargs)
        initialized_repositories[name] = nil
        repositories[name]             = RegisteredRepository.new(repository, **kwargs)       
      end

      def get_from_registry(name)
        repositories[name]
      end

      def initialize_repo(name)
        initialized_repositories[name] ||= get_from_registry(name).initialize_repo(self)
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