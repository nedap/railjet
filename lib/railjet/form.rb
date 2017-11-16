module Railjet
  module Form
    extend  ::ActiveSupport::Concern
    include Railjet::Validator

    included do
      const_set(:Error, Class.new(Railjet::FormError))
      
      def initialize(attributes = {})
        super(attributes.to_h)
      end
    end
  end
end
