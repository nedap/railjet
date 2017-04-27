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

    delegate :all_with_tasks, to: :record
    delegate :persist,        to: :cupido

    class ActiveRecordRepository
      include Railjet::Repository::ActiveRecord['DummyUserRecord']

      def all_with_tasks
        record.all.map do |user|
          user.tasks = registry.tasks.find_for_user(user)
          user
        end
      end
    end

    class CupidoRepository
      include Railjet::Repository::Cupido['DummyUserCupido']

      def persist(user)
        if registry.respond_to?(:settings) && registry.settings.call_cupido
          cupido.push(user)
        end
      end
    end
  end

  class DummyTaskRepository
    include Railjet::Repository::ActiveRecord['DummyTaskRecord']

    def find_for_user(user)
      record.where(user_id: user.id)
    end
  end

  before do
    registry.register(:user, DummyUserRepository)
    registry.register(:task, DummyTaskRepository)
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
      new_registry.users.persist(user)
    end

    it "does not change old registry" do
      expect(DummyUserRecord).not_to receive(:push)
      registry.users.persist(user)
    end
  end

  describe "overriding one of the repos" do
    let(:new_registry) { registry.clone }

    class DummyRoleRepository
      include Railjet::Repository
    end

    class AnotherTaskRepository
      include Railjet::Repository
    end

    before do
      new_registry.register(:role, DummyRoleRepository)
      new_registry.register(:task, AnotherTaskRepository)
    end

    it "adds new repository" do
      expect(new_registry.roles).to be_instance_of DummyRoleRepository
    end

    it "overrides old one" do
      expect(new_registry.tasks).to be_instance_of AnotherTaskRepository
    end

    it "does not change original" do
      expect(registry.tasks).to be_instance_of DummyTaskRepository
    end
  end
end