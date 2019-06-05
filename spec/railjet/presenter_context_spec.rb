require "railjet/presenter_context"

describe Railjet::PresenterContext do
  let(:repository)   { double("repository") }
  let(:context)      { double("context", repository: repository) }
  let(:view_context) { double("view_context") }

  subject(:presenter_context) { described_class.new(context, view_context) }

  it "gives access to view context" do
    expect(presenter_context.view).to eq view_context
  end

  it "removes repository" do
    expect { presenter_context.repository }.to raise_error NoMethodError
    expect(context.repository).to eq repository
  end
end