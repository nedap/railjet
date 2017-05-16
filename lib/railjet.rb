require "railjet/version"

require "active_support/concern"
require "active_model"
require "active_model/merge_errors"
require "virtus"
require "validates_timeliness"

module Railjet
  Error             = Class.new(StandardError)
  UnauthorizedError = Class.new(Error)
  RecordNotFound    = Class.new(Error)

  class ValidationError < Error
    attr_reader :errors

    def initialize(errors)
      @errors = errors
    end

    def error_messages
      errors.try(:messages)
    end

    def to_s
      error_messages
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
require "railjet/composed_policy"
require "railjet/use_case"

require "railjet/repository/registry"
require "railjet/repository"
require "railjet/repository/active_record"
require "railjet/repository/redis"
