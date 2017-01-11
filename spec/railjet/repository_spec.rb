require "railjet/repository"

describe Railjet::Repository do
  let(:registry) { double }
  let(:record)   { double('UserRecord') }
  let(:cupido)   { double('Cupido::User') }

  class DummyOneRepository
    include Railjet::Repository

    class CupidoRepository
      include Railjet::Repository::Cupido
    end
  end

  class DummyTwoRepository
    include Railjet::Repository

    class CupidoRepository
      include Railjet::Repository::Cupido
    end

    class ActiveRecordRepository
      include Railjet::Repository::ActiveRecord
    end
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
      subject(:repo)    { DummyOneRepository.new(registry, cupido: cupido) }
      let(:cupido_repo) { repo.send(:cupido) }

      it "creates single accessor" do
        expect(cupido_repo).to be_instance_of DummyOneRepository::CupidoRepository
        expect(cupido_repo.cupido).to eq cupido
      end

      it "does not create another accessor" do
        expect(repo.send(:record)).to be_nil
      end
    end

    context "with two DAO" do
      subject(:repo) { DummyTwoRepository.new(registry, record: record, cupido: cupido) }

      let(:record_repo) { repo.send(:record) }
      let(:cupido_repo) { repo.send(:cupido) }

      it "creates accessor for record" do
        expect(record_repo).to be_instance_of DummyTwoRepository::ActiveRecordRepository
        expect(record_repo.record).to eq record
      end

      it "creates accessor for cupido" do
        expect(cupido_repo).to be_instance_of DummyTwoRepository::CupidoRepository
        expect(cupido_repo.cupido).to eq cupido
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