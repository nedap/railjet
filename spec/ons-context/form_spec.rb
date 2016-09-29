require "ons-context/form"

describe OnsContext::Form do
  class DummyForm
    include OnsContext::Form

    attribute :name, String
    validates :name, presence: true
  end

  describe "#validate!" do
    context "valid" do
      let(:form) { DummyForm.new(name: "John") }

      it "return true" do
        expect(form.validate!).to be true
      end
    end

    context "invalid" do
      let(:form) { DummyForm.new }

      it "raises exception" do
        expect { form.validate! }.to raise_exception(OnsContext::ValidationError) do |e|
          expect(e.errors["name"]).to include "can't be blank"
        end
      end
    end
  end
end
