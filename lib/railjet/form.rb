module Railjet
  module Form
    extend  ::ActiveSupport::Concern
    include Railjet::Validator

    def validate!
      valid? || (raise Railjet::FormError.new(errors) )
    end
  end
end
