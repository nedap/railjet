module Railjet
  module Form
    extend  ::ActiveSupport::Concern
    include Railjet::Validator

    included do
      const_set(:Error, Class.new(Railjet::FormError))
    end
  end
end
