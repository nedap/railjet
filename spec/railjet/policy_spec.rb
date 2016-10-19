require "railjet/policy"

describe Railjet::Policy do
  class DummyBeforeDeadlinePolicy
    include Railjet::Policy

    object  :registration
    context :settings

    delegate :date,     to: :registration
    delegate :deadline, to: :settings

    validate :date_before_deadline, if: :deadline

    private

    def date_before_deadline
      errors.add(:base, "Oops, deadline exceeded") if date > deadline
    end
  end

  let(:app_context) { double(settings: settings) }

  context "invalid" do
    subject(:policy) { DummyBeforeDeadlinePolicy.new(app_context, registration) }

    let(:registration) { double(date:     Date.parse('01-01-2016')) }
    let(:settings)     { double(deadline: Date.parse('31-12-2015')) }

    it "raises exception" do
      expect { policy.validate! }.to raise_exception(Railjet::PolicyError) do |e|
        expect(e.errors[:base]).to include /deadline exceeded/
      end
    end
  end

  context "valid" do
    subject(:policy) { DummyBeforeDeadlinePolicy.new(app_context, registration) }

    let(:registration) { double(date: Date.parse('01-01-2016')) }
    let(:settings)     { double(deadline: nil) }

    it "returns true" do
      expect(policy.validate!).to be true
    end
  end
end