module OnsContext
  class ComposedPolicy
    class_attribute :policies

    attr_reader :context, :object
    attr_reader :policies

    def self.add(policy, after: nil, before: nil)
      self.policies ||= []

      if after
        self.policies = policies.dup.insert(policies.index(after) + 1, policy)
      elsif before
        self.policies = policies.dup.insert(policies.index(before), policy)
      else
        self.policies += [policy]
      end
    end

    def initialize(context, object)
      @context, @object = context, object

      @policies = self.class.policies.map do |policy|
        policy.new(context, object)
      end
    end

    def valid?
      policies.map(&:valid?).all?
    end

    def errors
      valid?
      policies.map(&:errors).inject(&:<<)
    end

    def validate!
      policies.each(&:validate!)
    end
  end
end
