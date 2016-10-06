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
    end
  end
end
