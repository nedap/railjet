module OnsContext
  module Form
    extend  ::ActiveSupport::Concern
    include ::ActiveModel::Model

    included do
      include Virtus.model(nullify_blank: true)
    end

    def validate!
      valid? || (raise OnsContext::FormError.new(errors) )
    end
  end
end
