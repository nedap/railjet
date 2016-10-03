module OnsContext
  module Auth
    class Activity
      attr_reader :settings, :object

      def initialize(settings, object)
        @settings = settings
        @object   = object
      end
    end
  end
end
