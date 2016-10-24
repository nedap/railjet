require "railjet/repository"

describe Railjet::Repository do
  let(:registry) { double }
  let(:record)   { double('UserRecord') }
  let(:cupido)   { double('Cupido::User') }

  class DummyOneRepository
    include Railjet::Repository
  end

  class DummyTwoRepository
    include Railjet::Repository
  end

  class AnotherDummyRepository
    include Railjet::Repository

    def foo
      record.foo
    end

    private

    def record
      @record ||= FooRepository.new(super)
    end

    class FooRepository < Struct.new(:record)
      def foo
        "Bar"
      end
    end
  end

  describe "#new" do
    context "with one DAO" do
      subject(:repo) { DummyOneRepository.new(registry, cupido: cupido) }

      it "creates single accessor" do
        expect(repo.send(:cupido)).to eq cupido
      end

      it "does not create another accessor" do
        expect { repo.send(:record) }.to raise_exception(NoMethodError)
      end
    end

    context "with two DAO" do
      subject(:repo) { DummyTwoRepository.new(registry, record: record, cupido: cupido) }

      it "creates private accessors" do
        expect(repo.send(:record)).to eq record
        expect(repo.send(:cupido)).to eq cupido
      end
    end

    describe "overriding accessors" do
      subject(:repo) { AnotherDummyRepository.new(registry, record: record) }

      it "works with super" do
        expect(repo.foo).to eq "Bar"
      end
    end
  end
end