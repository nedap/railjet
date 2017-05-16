module Railjet
  module Form
    extend  ::ActiveSupport::Concern
    include Railjet::Validator

    included do
      const_set(:Error, Class.new(Railjet::FormError))
    end

    def validate!
      valid? || (raise self.class::Error.new(errors))
    end
  end
end
