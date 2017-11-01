begin
  require "wisper/testing"
rescue LoadError
  puts "Railjet::EventBus::Testing will only work in test environment"
end

module Railjet
  class EventBus
    module Testing
      class << self
        delegate :adapter, to: EventBus
        delegate :clear,   to: :adapter
        delegate :inline,  to: :testing

        def testing
          adapter::Testing
        end
      end
    end
  end
end