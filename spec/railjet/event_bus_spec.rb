require "railjet/event_bus"

describe Railjet::EventBus do
  before :all do
    described_class.run_inline!
  end

  describe "pub/sub" do
    subject(:bus) { described_class.new("dummy") }

    it "fires up subscriber when event is published" do
      received = false

      bus.subscribe "dummy_created" do
        received = true
      end



      expect(received).to be false

      bus.publish("dummy_created", id: 1)

      expect(received).to be true
    end

    it "passes in given attributes" do
      received_attrs = nil

      bus.subscribe "dummy_created" do |attrs|
        received_attrs = attrs
      end

      bus.publish("dummy_created", id: 1)

      expect(received_attrs).to include "id"
      expect(received_attrs.length).to eq 11
    end

    it "splits block argument into attrs and bus payload" do
      received_attrs   = nil
      received_payload = nil

      bus.subscribe "dummy_created" do |attrs, payload|
        received_attrs   = attrs
        received_payload = payload
      end

      bus.publish("dummy_created", id: 1)

      expect(received_attrs.length).to eq 1
      expect(received_payload.length).to eq 10
    end
  end
end
