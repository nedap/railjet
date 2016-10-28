require "railjet/repository/registry"

describe Railjet::Repository::Registry do
  let(:app_registry) { Class.new(described_class).new }

  let(:query)  { double('UserRecord') }
  let(:cupido) { double('Cupido::User') }

  class DummyRepository
    def initialize(registry, **kwargs)
    end
  end

  before do
    app_registry.register(:user, DummyRepository, query: query, cupido: cupido)
  end

  describe "#register" do
    it "creates accessor method" do
      expect(app_registry).to respond_to :users
    end

    it "initializes repository with given models" do
      expect(DummyRepository).to receive(:new).with(app_registry, query: query, cupido: cupido)
      app_registry.users
    end
  end

  describe "#new" do
    let(:settings)     { double(deadline: Date.today) }
    let(:new_registry) { app_registry.new(settings: settings) }

    it "creates accessor for passed in arguments" do
      expect(new_registry.settings).to eq settings
    end

    it "copies all repositories" do
      expect(new_registry).to respond_to :users
    end

    it "does not change original registry" do
      expect(app_registry).not_to respond_to :settings
    end
  end
end