require "railjet/repository"

describe Railjet::Repository do
  let(:registry) { double }

  class DummyRecord
  end

  class DummyCupido
  end

  class DummyOneRepository
    include Railjet::Repository::Cupido[cupido: 'DummyCupido']
  end

  class DummyTwoRepository
    include Railjet::Repository

    class CupidoRepository
      include Railjet::Repository::Cupido[cupido: 'DummyCupido']
    end

    class ActiveRecordRepository
      include Railjet::Repository::ActiveRecord[record: 'DummyRecord']
    end
  end

  describe "#new" do
    context "with one DAO" do
      subject(:repo)    { DummyOneRepository.new(registry) }
      let(:cupido_repo) { repo.send(:cupido) }

      it "creates accessor for DAO" do
        expect(repo.cupido).to be DummyCupido
      end
    end

    context "with two DAO" do
      subject(:repo) { DummyTwoRepository.new(registry) }

      let(:record_repo) { repo.send(:record) }
      let(:cupido_repo) { repo.send(:cupido) }

      it "creates accessor for record" do
        expect(record_repo).to be_instance_of DummyTwoRepository::ActiveRecordRepository
        expect(record_repo.record).to eq DummyRecord
      end

      it "creates accessor for cupido" do
        expect(cupido_repo).to be_instance_of DummyTwoRepository::CupidoRepository
        expect(cupido_repo.cupido).to eq DummyCupido
      end
    end
  end
end