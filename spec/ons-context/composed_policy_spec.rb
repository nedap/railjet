require "ons-context/composed_policy"
require "ons-context/policy"

describe OnsContext::ComposedPolicy do
  class DummyFirstPolicy
    include OnsContext::Policy

    validates_absence_of :foo

    def foo
      nil
    end
  end

  class DummySecondPolicy
    include OnsContext::Policy

    validates_absence_of :foo

    def foo
      "foo"
    end
  end

  class DummyThirdPolicy
    include OnsContext::Policy

    validates_absence_of :bar

    def bar
      "bar"
    end
  end


  class DummyDeclarePolicy < OnsContext::ComposedPolicy
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
      expect { composed_policy.validate! }.to raise_exception(OnsContext::PolicyError) do |e|
        errors = e.errors

        expect(errors).to     include :foo
        expect(errors).not_to include :bar
      end
    end
  end
end
