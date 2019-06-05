require "railjet/context"

describe Railjet::Context do
  class DummyAppContext < Railjet::Context
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

  it "does not share writers between instances" do
    context.foo = "bar"
    new_context = DummyAppContext.new(current_employee: current_employee, repository: repository)

    expect { new_context.foo = "foo" }.not_to raise_error
    expect(new_context.foo).to eq "foo"
  end

  it "does not allow editing values" do
    expect { context.current_employee = "something else" }.to raise_exception(NoMethodError)
  end
end
