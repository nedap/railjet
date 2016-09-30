module OnsContext
  module Form
    extend  ::ActiveSupport::Concern
    include OnsContext::Validator

    def validate!
      valid? || (raise OnsContext::FormError.new(errors) )
    end
  end
end
