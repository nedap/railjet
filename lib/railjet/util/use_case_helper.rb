module Railjet
  module Util
    module UseCaseHelper
      def use_case(klass)
        klass.new(context)
      end
    end
  end
end
