require "railjet/presenter"

class DummyClientPresenter
  include Railjet::Presenter
  object :client

  def as_json(*)
    {
      id:   client.id,
      name: client.display_name
    }
  end
end

class DummyEmployeePresenter
  include Railjet::Presenter::WithContext
  context :current_ability
  object  :employee

  def as_json(*)
    {
      id:   employee.id,
      name: employee.display_name,

      can_edit_events: current_ability.can_edit_events?
    }
  end
end

class DummyPresenterFactory
  include Railjet::Presenter::Factory

  def self.presenter_class(object)
    if object.client?
      DummyClientPresenter
    else
      DummyEmployeePresenter
    end
  end
end

describe Railjet::Presenter do
  let(:client_one) { double(id: 1, display_name: "John Doe") }
  let(:client_two) { double(id: 2, display_name: "Anna Doe") }

  describe "::present" do
    subject(:presenter) { DummyClientPresenter.present(client_one) }

    it "creates an accessor for @object ivar" do
      expect(presenter.as_json).to eq({ id: 1, name: "John Doe" })
    end
  end

  describe "::present_collection" do
    subject(:presenters) { DummyClientPresenter.present_collection([client_one, client_two]) }

    it "can be initialized with multiple objects" do
      expect(presenters.map(&:as_json)).to eq([{ id: 1, name: "John Doe" }, { id: 2, name: "Anna Doe" }])
    end
  end
end

describe Railjet::Presenter::WithContext do
  let(:employee_one)    { double(id: 1, display_name: "John Doe") }
  let(:employee_two)    { double(id: 2, display_name: "Anna Doe") }

  let(:context)         { double(current_ability: current_ability) }
  let(:current_ability) { double(can_edit_events?: true) }

  describe "::initialize" do
    let(:presenter) { DummyEmployeePresenter.present(context, employee_one) }

    it "can be initialized with context" do
      expect(presenter.as_json).to eq({ id: 1, name: "John Doe", can_edit_events: true })
    end
  end

  describe "::present_collection" do
    subject(:presenters) { DummyEmployeePresenter.present_collection(context, [employee_one, employee_two]) }

    it "can be initialized with context and multiple objects" do
      expect(presenters.map(&:as_json)).to eq([{ id: 1, name: "John Doe", can_edit_events: true }, { id: 2, name: "Anna Doe", can_edit_events: true }])
    end
  end
end

describe Railjet::Presenter::Factory do
  subject(:presenter) { DummyPresenterFactory.present_collection([object]) }
  let(:object) { double(client?: true) }

  it "initializes proper presenter based on #presenter_class method" do
    expect(presenter[0]).to be_instance_of DummyClientPresenter
  end
end