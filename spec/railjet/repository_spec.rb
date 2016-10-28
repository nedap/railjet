require "railjet/repository/registry"
require "railjet/repository"

describe Railjet::Repository::Registry do
  let(:app_registry) { Class.new(described_class).new }

  let(:query)  { double('UserRecord') }
  let(:cupido) { double('Cupido::User') }

  let(:repo) do
    Class.new do
      include Railjet::Repository
      include Railjet::Repository::ActiveRecordRepository
      include Railjet::Repository::CupidoRepository

      def build_user(hash = {})
        query.new(hash)
      end

      def push_user(hash = {})
        cupido.push(hash)
      end
    end
  end

  before do
    app_registry.register(:user, repo, query: query, cupido: cupido)
  end

  describe "#register" do
    it "creates accessor method" do
      expect(app_registry).to respond_to :users
    end

    describe "defined accessor" do
      let(:users) { app_registry.users }

      it "calls ActiveRecord properly" do
        expect(query).to receive(:new).with(name: "John Doe")
        users.build_user(name: "John Doe")
      end

      it "calls Cupido properly" do
        expect(cupido).to receive(:push).with(name: "John Doe")
        users.push_user(name: "John Doe")
      end
    end

    describe "overriding accessors" do
      let(:repo) do
        Class.new do
          include Railjet::Repository

          def find_foo
            query.foo
          end

          private

          def query
            @query ||= FooRepository.new(super)
          end

          class FooRepository
            def initialize(query)
              @query = query
            end

            def foo
              "Foo"
            end
          end
        end
      end

      let(:users) { app_registry.users }

      it "works with #super" do
        expect(users.find_foo).to eq "Foo"
      end
    end
  end

  describe "#new" do
    let(:settings) { double(deadline: Date.today) }
    let(:new_registry) { app_registry.new(settings: settings) }

    it "creates accessor for passed in arguments" do
      expect(new_registry.settings).to eq settings
      expect(app_registry).not_to respond_to(:settings)
    end
    
    it "has repositories defines" do
      expect(new_registry).to respond_to :users
    end
  end
end