require "ons-context/use_case"

describe OnsContext::UseCase do
  let(:app_context)  { double(current_user: "John") }

  it "can be initialized with context" do
    DummyCreateArticle.new(app_context)
  end

  describe "call" do
    subject(:use_case) { DummyCreateArticle.new(app_context) }
    let(:form) { double(title: "Foo", content: "...") }

    it "uses current_user from context" do
      article = use_case.call(form)

      expect(article.title).to eq "Foo"
      expect(article.creator).to eq "John"
    end
  end

  describe "ability check" do
    subject(:use_case) { DummyCreateArticleWithAuth.new(app_context) }

    let(:user)         { double(name: "John")}
    let(:ability)      { double(can_create_article?: nil) }
    let(:app_context)  { double(current_user: user, current_ability: ability) }

    let(:form) { double(title: "Foo", content: "...") }

    context "unauthorized" do
      before do
        expect(ability).to receive(:can_create_article?).with(user).and_return false
      end

      it "raises exception" do
        expect { use_case.call(form) }.to raise_exception(OnsContext::UnauthorizedError)
      end
    end

    context "authorized" do
      before do
        expect(ability).to receive(:can_create_article?).with(user).and_return true
      end

      it "raises exception" do
        article = use_case.call(form)
        expect(article.creator).to eq user
      end
    end
  end

  describe "policy check" do
    subject(:use_case) { DummyCreateArticleWithPolicy.new(app_context) }

    let(:user)        { double(name: "Johh") }
    let(:app_context) { double(current_user: user) }

    let(:form) { double(title: "Foo", content: "...") }

    context "unauthorized" do
      before do
        expect(user).to receive(:admin?).and_return false
      end

      it "raises exception" do
        expect { use_case.call(form) }.to raise_exception(OnsContext::PolicyError) do |e|
          expect(e.errors[:user]).to include "not an admin"
        end
      end
    end

    context "authorized" do
      before do
        expect(user).to receive(:admin?).and_return true
      end

      it "raises exception" do
        article = use_case.call(form)
        expect(article.creator).to eq user
      end
    end
  end
end


class DummyCreateArticle
  include OnsContext::UseCase

  context :current_user

  def call(form)
    Article.new(form.title, form.content, current_user)
  end

  class Article < Struct.new(:title, :content, :creator)
  end
end

class DummyCreateArticleWithAuth < DummyCreateArticle
  check_ability :can_create_article?

  def call(form)
    with_ability_check(current_user) do
      super
    end
  end
end

class DummyCreateArticleWithPolicy < DummyCreateArticle
  check_policy { |user| policy(DummyPolicy, user) }

  def call(form)
    with_policy_check(current_user) do
      super
    end
  end
end

class DummyPolicy
  attr_reader :context, :user

  def initialize(context, user)
    @context, @user = context, user
  end

  def validate!
    raise OnsContext::PolicyError.new({ user: ["not an admin"]} ) unless user.admin?
  end
end