require "ons-context/version"

require "active_support"
require "active_model"
require "virtus"

module OnsContext
  Error             = Class.new(StandardError)
  UnauthorizedError = Class.new(Error)

  class ValidationError < Error
    attr_reader :errors

    def initialize(errors)
      @errors = errors
    end

    def error_messages
      errors.try(:messages)
    end
  end

  FormError   = Class.new(ValidationError)
  PolicyError = Class.new(ValidationError)
  PolicyNotMetError = Class.new(PolicyError)
end

require "ons-context/validator"
require "ons-context/form"
require "ons-context/policy"
require "ons-context/use_case"
