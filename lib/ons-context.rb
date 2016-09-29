require "ons-context/version"

require "active_support"
require "active_model"
require "virtus"

module OnsContext
  class Error < StandardError
  end

  class ValidationError < Error
    attr_reader :errors

    def initialize(errors)
      @errors = errors
    end

    def error_messages
      errors.try(:messages)
    end
  end
end
