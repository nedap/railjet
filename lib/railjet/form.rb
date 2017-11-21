module Railjet
  module Form
    extend  ::ActiveSupport::Concern
    include Railjet::Validator

    included do
      const_set(:Error, Class.new(Railjet::FormError))
      
      def initialize(attributes = {})
        super(attributes.respond_to?(:to_unsafe_h) ? attributes.to_unsafe_h : attributes)
      end
    end
  end
end
