require "sidekiq/testing"
require "railjet/event_bus"

describe Railjet::EventBus do
  around(:each) do |example|
    Wisper.clear

    Sidekiq::Testing.inline! do
      example.run
    end
  end

  class DummyPublisher
    include Railjet::Publisher

    def self.call(*args)
      new.call(*args)
    end

    def call(*args)
      publish(:dummy_created, *args)
    end
  end

  class DummySubscriber
    def self.on_dummy_created(*args)
      # mocked
    end
  end

  describe "pub/sub" do
    subject(:bus) { described_class.new }

    before do
      bus.subscribe :dummy_created, DummySubscriber
    end

    it "fires up subscriber when event is published" do
      expect(DummySubscriber).to receive(:on_dummy_created)
      DummyPublisher.call
    end

    it "passes in given attributes" do
      expect(DummySubscriber).to receive(:on_dummy_created).with(id: 1)
      DummyPublisher.call(id: 1)
    end
  end
end
