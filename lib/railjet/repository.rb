module Railjet
  module Repository
    attr_reader :registry
    delegate    :settings, to: :registry

    def initialize(registry, **kwargs)
      @registry = registry
      initialize_specific_repositories(**kwargs)
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

    def initialize_specific_repositories(**kwargs)
      repositories.each do |repo|
        initialize_repository(repo, **kwargs)
      end
    end

    private

    def initialize_repository(repository, **kwargs)
      ivar = "@#{repository.type}"
      dao  = kwargs[repository.type]

      instance_variable_set(ivar, repository.new(registry, :"#{repository.type}" => dao))
      self.class.send :attr_reader, repository.type
    end
  end
end
