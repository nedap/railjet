module OnsContext
  module Form
    extend  ::ActiveSupport::Concern
    include ::ActiveModel::Model

    included do
      include Virtus.model(nullify_blank: true)
    end

    def validate!
      valid? or raise OnsContext::ValidationError.new(errors)
    end
  end
end
