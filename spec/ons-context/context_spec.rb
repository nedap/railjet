require "ons-context/context"

describe OnsContext::Context do
  class DummyAppContext < OnsContext::Context
    def initialize(current_employee:, repository:)
      super
    end
  end

  let(:current_employee) { double }
  let(:repository)       { double }

  let(:context) { DummyAppContext.new(current_employee: current_employee, repository: repository) }

  it "has accessor for each argument" do
    expect(context.current_employee).to eq current_employee
    expect(context).not_to respond_to :current_employee=

    expect(context.repository).to eq repository
    expect(context).not_to respond_to :repository=
  end

  it "has writers for new values" do
    context.foo = "bar"

    expect(context.foo).to eq "bar"

    expect { context.foo = "foo" }.to raise_exception(NoMethodError)
  end

  it "does not allow editing values" do
    expect { context.current_employee = "something else" }.to raise_exception(NoMethodError)
  end
end
