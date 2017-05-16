module Railjet
  module Policy
    extend  ::ActiveSupport::Concern
    include Railjet::Validator

    included do
      const_set(:Error, Class.new(Railjet::PolicyError))
    end

    def initialize(context, object)
      @context, @object = context, object
    end
    
    attr_reader :context, :object

    module ClassMethods
      def context(*context_members)
        delegate *context_members, to: :context
      end

      def object(name)
        alias_method name, :object
      end
    end
  end
end
