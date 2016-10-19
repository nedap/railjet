require "railjet/composed_policy"
require "railjet/policy"

describe Railjet::ComposedPolicy do
  class DummyFirstPolicy
    include Railjet::Policy

    validates_absence_of :foo

    def foo
      nil
    end
  end

  class DummySecondPolicy
    include Railjet::Policy

    validates_absence_of :foo

    def foo
      "foo"
    end
  end

  class DummyThirdPolicy
    include Railjet::Policy

    validates_absence_of :bar

    def bar
      "bar"
    end
  end


  class DummyDeclarePolicy < Railjet::ComposedPolicy
    add DummyThirdPolicy
    add DummySecondPolicy, before: DummyThirdPolicy
    add DummyFirstPolicy,  after:  DummySecondPolicy
  end

  let(:registration) { double }
  let(:app_context)  { double }

  describe "#errors" do
    let(:composed_policy) { DummyDeclarePolicy.new(app_context, registration) }
    subject(:errors)      { composed_policy.errors }

    it "gives errors from all policies combined" do
      expect(errors).to include :foo
      expect(errors).to include :bar
    end
  end

  describe "#validate!" do
    let(:composed_policy) { DummyDeclarePolicy.new(app_context, registration) }

    it "raises exception from first invalid policy" do
      expect { composed_policy.validate! }.to raise_exception(Railjet::PolicyError) do |e|
        errors = e.errors

        expect(errors).to     include :foo
        expect(errors).not_to include :bar
      end
    end
  end
end
