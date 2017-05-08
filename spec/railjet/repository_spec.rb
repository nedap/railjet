require "railjet/repository"

describe Railjet::Repository do
  let(:registry) { double }

  DummyRecord = Class.new
  DummyRedis  = Class.new

  class DummyOneRepository
    include Railjet::Repository::ActiveRecord['DummyRecord']
  end

  class DummyTwoRepository
    include Railjet::Repository

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
      let(:record_repo) { repo.send(:record) }

      it "creates accessor for DAO" do
        expect(repo.record).to be DummyRecord
      end
    end

    context "with multiple DAO" do
      subject(:repo) { DummyTwoRepository.new(registry) }

      let(:record_repo) { repo.send(:record) }
      let(:redis_repo)  { repo.send(:redis)  }

      it "creates accessor for record" do
        expect(record_repo).to be_instance_of DummyTwoRepository::ActiveRecordRepository
        expect(record_repo.record).to eq DummyRecord
      end

      it "creates accessor for redis" do
        expect(redis_repo).to be_instance_of DummyTwoRepository::RedisRepository
        expect(redis_repo.redis).to eq DummyRedis
      end
    end
  end
end