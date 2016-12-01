require "active_support"
require "active_model"
require "active_model/merge_errors"
require "virtus"

module Railjet
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

require "railjet/context"

require "railjet/util/use_case_helper"
require "railjet/util/policy_helper"
require "railjet/util/form_helper"

require "railjet/validator"
require "railjet/form"
require "railjet/policy"
require "railjet/use_case"

require "railjet/repository/registry"
require "railjet/repository"

require "railjet/railtie" if defined?(Rails)
