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

  let(:record_repo) { repo.send(:record) }
  let(:cupido_repo) { repo.send(:cupido) }
  let(:redis_repo)  { repo.send(:redis)  }

  describe "#new" do
    context "with one DAO" do
      subject(:repo)    { DummyOneRepository.new(registry) }

      it "creates accessor for DAO" do
        expect(repo.record).to be DummyRecord
      end
    end

    context "with multiple DAO" do
      subject(:repo) { DummyTwoRepository.new(registry) }

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
  
  describe "initialized repo" do
    subject(:repo) { DummyOneRepository.new(registry) }
    
    it "responds to methods from included repo" do
      expect(repo).to respond_to :persist
    end
  end

  describe "overriding default DAO" do
    let(:record_dao) { double }
    let(:redis_dao)  { double }

    subject(:repo) { DummyTwoRepository.new(registry, record: record_dao, redis: redis_dao) }

    it "changes record DAO" do
      expect(record_repo).to be_instance_of DummyTwoRepository::ActiveRecordRepository
      expect(record_repo.record).to eq record_dao
    end

    it "changes redis DAO" do
      expect(redis_repo).to be_instance_of DummyTwoRepository::RedisRepository
      expect(redis_repo.redis).to eq redis_dao
    end
  end
end
