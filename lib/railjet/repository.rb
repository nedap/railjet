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
      klass         = self.class
      inner_klasses = klass.constants
      inner_repos   = inner_klasses.select { |k| k.to_s.end_with?("Repository") }
      
      inner_repos.map do |k|
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
