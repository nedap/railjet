module Railjet
  module Policy
    extend  ::ActiveSupport::Concern
    include Railjet::Validator

    attr_reader :context, :object

    def initialize(context, object)
      @context, @object = context, object
    end

    def validate!
      valid? || (raise Railjet::PolicyError.new(errors) )
    end

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
