module Railjet
  module Repository
    attr_reader :registry
    delegate    :settings, to: :registry

    def initialize(registry)
      @registry = registry
      initialize_specific_repositories
    end

    private

    def repositories
      klass = self.class

      klass.constants.select do |k|
        name = klass.const_get(k).name
        name.end_with?("Repository")
      end.map do |k|
        klass.const_get(k)
      end
    end

    def initialize_specific_repositories
      repositories.each do |repo|
        initialize_repository(repo)
      end
    end

    private

    def initialize_repository(repository)
      ivar = "@#{repository.type}"
      instance_variable_set(ivar, repository.new(registry))
      self.class.send :attr_reader, repository.type
    end
  end
end
