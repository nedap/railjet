module Railjet
  # @private Use either form or policy
  module Validator
    extend  ::ActiveSupport::Concern
    include ::ActiveModel::Model

    included do
      include Virtus.model(nullify_blank: true)
    end

    def validate!
      valid? || (raise self.class::Error.new(errors))
    end
  end
end
