module Railjet
  class EventBus
    class << self
      attr_accessor :adapter

      def run_inline!
        adapter.local_mode = :inline
      end
    end

    def initialize(queue, adapter: self.class.adapter)
      @bus        = adapter or raise ArgumentError, "Railjet::EventBus adapter must be specified"
      @dispatcher = adapter.dispatch(queue) { }
    end

    def publish(event, attrs = {})
      bus.publish(event, attrs)
    end

    def subscribe(event, &block)
      dispatcher.instance_eval do
        subscribe(event, &ProcSubscriber.new(&block))
      end
    end

    private

    attr_reader :bus, :dispatcher

    class ProcSubscriber < Proc
      def initialize(&subscriber)
        @subscriber = subscriber
      end

      def call(attributes)
        return super unless subscriber.arity == 2
        subscriber.call(attrs(attributes), payload(attributes))
      end

      private

      def payload(attributes)
        payload = attributes.select(&method(:bus_payload?))
        payload = payload.with_indifferent_access if payload.respond_to?(:with_indifferent_access)

        payload
      end

      def attrs(attributes)
        attrs = attributes.reject(&method(:bus_payload?))
        attrs = attrs.with_indifferent_access if attrs.respond_to?(:with_indifferent_access)

        attrs
      end

      def bus_payload?(k, v)
        k =~ /bus_/
      end

      attr_reader :subscriber
    end
  end
end
