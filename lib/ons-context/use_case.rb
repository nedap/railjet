module OnsContext
  module UseCase
    extend ActiveSupport::Concern
    include ::OnsContext::Util::UseCaseHelper
    include ::OnsContext::Util::PolicyHelper

    attr_reader :context

    def initialize(context)
      @context = context
    end

    def with_ability_check(*args)
      if check_ability!(*args)
        yield if block_given?
      else
        raise OnsContext::UnauthorizedError
      end
    end

    def with_policy_check(*args)
      check_policy!(*args)
      yield if block_given?
    rescue OnsContext::PolicyError => e
      raise OnsContext::PolicyNotMetError.new(e.errors)
    end

    def check_ability!(*args)
      true
    end

    def check_policy!(*args)
      true
    end

    module ClassMethods
      def context(*context_members)
        delegate *context_members, to: :context
      end
      
      def repositories(*repositories)
        context :repository
        delegate *repositories, to: :repository
      end

      def check_ability(ability_name)
        define_method :check_ability! do |*args|
          context.current_ability.send(ability_name, *args)
        end
      end

      def check_policy(&block)
        define_method :check_policy!, &block
      end
    end
  end
end