module OnsContext
  module Util
    module FormHelper
      def form(klass)
        klass.new(clean_params).validate!
      end

      private

      def object_params
        raise NotImplementedError
      end

      def clean_params
        object_params
      end

      def respond_with_errors(object_with_errors)
        raise ArgumentError unless object_with_errors.respond_to?(:errors)

        response = object_with_errors.errors.to_hash(true)
        render json: response, status: :unprocessable_entity
      end
    end
  end
end
