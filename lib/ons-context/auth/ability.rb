module OnsContext
  module Auth
    class Ability
      attr_reader :actor, :settings

      def initialize(actor, settings)
        @actor    = actor
        @settings = settings

        @activities = {}
      end

      private

      def activity(klass, object)
        @activities[klass] ||= klass.new(object, settings)
      end
    end
  end
end
