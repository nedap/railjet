require "railjet/repository"
require "railjet/repository/registry"

describe "Repository & Registry" do
  let(:registry) { Railjet::Repository::Registry.new }

  class DummyUserRecord < Struct.new(:id)
    attr_accessor :tasks
  end

  class DummyUserCupido
  end

  class DummyTaskRecord < Struct.new(:id)
  end

  class DummyUserRepository
    include Railjet::Repository
    include Railjet::Repository::ActiveRecordRepository
    include Railjet::Repository::CupidoRepository

    def all_with_tasks
      query.all.map do |user|
        user.tasks = registry.tasks.find_for_user(user)
        user
      end
    end

    def save_in_cupido(user)
      if registry.respond_to?(:settings) && registry.settings.call_cupido
        cupido.push(user)
      end
    end
  end

  class DummyTaskRepository
    include Railjet::Repository
    include Railjet::Repository::ActiveRecordRepository

    def find_for_user(user)
      query.where(user_id: user.id)
    end
  end

  before do
    registry.register(:user, DummyUserRepository, query: DummyUserRecord, cupido: DummyUserCupido)
    registry.register(:task, DummyTaskRepository, query: DummyTaskRecord)
  end

  describe "calling another repo" do
    let(:user_one) { DummyUserRecord.new(1) }
    let(:user_two) { DummyUserRecord.new(2) }

    let(:task_one) { DummyTaskRecord.new(1) }
    let(:task_two) { DummyTaskRecord.new(2) }

    it "calls repo" do
      expect(DummyUserRecord).to receive(:all).and_return([user_one, user_two])
      expect(DummyTaskRecord).to receive(:where).with(user_id: 1).and_return([task_one])
      expect(DummyTaskRecord).to receive(:where).with(user_id: 2).and_return([task_two])

      users = registry.users.all_with_tasks

      expect(users[0]).to eq user_one
      expect(users[0].tasks[0]).to eq task_one

      expect(users[1]).to eq user_two
      expect(users[1].tasks[0]).to eq task_two
    end
  end

  describe "creating per-request copy" do
    let(:settings)     { double(call_cupido: true) }
    let(:new_registry) { registry.new(settings: settings) }

    let(:user) { DummyUserRecord.new(1) }

    it "adds per-request accessors" do
      expect(DummyUserCupido).to receive(:push).with(user)
      new_registry.users.save_in_cupido(user)
    end

    it "does not change old registry" do
      expect(DummyUserRecord).not_to receive(:push)
      registry.users.save_in_cupido(user)
    end
  end
end