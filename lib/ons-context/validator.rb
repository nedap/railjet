module OnsContext
  # @private Use either form or policy
  module Validator
    extend  ::ActiveSupport::Concern
    include ::ActiveModel::Model

    included do
      include Virtus.model(nullify_blank: true)
    end

    def validate!
      raise NotImplementedError
    end
  end
end
