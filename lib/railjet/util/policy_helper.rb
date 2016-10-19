module Railjet
  module Util
    module PolicyHelper
      def policy(klass, *args)
        klass.new(context, *args).validate!
      end
    end
  end
end
