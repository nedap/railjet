require "railjet/repository"

describe Railjet::Repository do
  let(:registry) { double }

  DummyRecord = Class.new
  DummyCupido = Class.new
  DummyRedis  = Class.new

  class DummyOneRepository
    include Railjet::Repository::Cupido['DummyCupido']
  end

  class DummyTwoRepository
    include Railjet::Repository

    class CupidoRepository
      include Railjet::Repository::Cupido['DummyCupido']
    end

    class ActiveRecordRepository
      include Railjet::Repository::ActiveRecord['DummyRecord']
    end

    class RedisRepository
      include Railjet::Repository::Redis['DummyRedis']
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

    context "with multiple DAO" do
      subject(:repo) { DummyTwoRepository.new(registry) }

      let(:record_repo) { repo.send(:record) }
      let(:cupido_repo) { repo.send(:cupido) }
      let(:redis_repo)  { repo.send(:redis)  }

      it "creates accessor for record" do
        expect(record_repo).to be_instance_of DummyTwoRepository::ActiveRecordRepository
        expect(record_repo.record).to eq DummyRecord
      end

      it "creates accessor for cupido" do
        expect(cupido_repo).to be_instance_of DummyTwoRepository::CupidoRepository
        expect(cupido_repo.cupido).to eq DummyCupido
      end

      it "creates accessor for redis" do
        expect(redis_repo).to be_instance_of DummyTwoRepository::RedisRepository
        expect(redis_repo.redis).to eq DummyRedis
      end
    end
  end
end