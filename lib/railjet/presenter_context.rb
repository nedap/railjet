module Railjet
  class PresenterContext < SimpleDelegator
    attr_reader :view

    def initialize(context, view_context)
      super(context)
      @view = view_context
    end

    def repository
      raise NoMethodError, "Acessing Repository from Presenter is a no-no 🙅‍♂️"
    end
  end
end