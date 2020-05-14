# frozen_string_literal: true

module Railjet
  module Console
    # Adds helper methods for auditing of console customer usage
    module RailjetHelpers
      def setup_railjet(context_class: nil)
        @context_class = context_class

        @context_class ||= RailjetContextHelper.determine_context_class

        railjet_helper_after_init_message
      end

      def railjet_helper_after_init_message
        puts 'Setup finished. railjet helpers are now available from console'
        puts 'available commands:'
        puts "\t- use_case(<Class>)"
        puts "\t- form(<Class>, params)"
        puts "\t- console_context"
      end

      def railjet_helper_after_load_message
        puts '*' * 61
        puts "\nCall 'setup_railjet' to setup and debug Railjet"
        puts 'Argument are:'
        method(:setup_railjet).parameters.each do |param|
          case param[0]
          when :key, :keyreq
            puts "\t- #{param[1]}:"
          else
            puts "\t- #{param[1]}"
          end
        end
        puts "\n"
        puts '*' * 61
      end

      def console_context
        @context_class.init(
          *context_params
        )
      end

      def use_case(klass)
        klass.new(console_context)
      end

      def form(klass, clean_params)
        klass.new(clean_params).tap(&:validate)
      end

      def context_params
        parameters, missing_methods = find_context_params

        RailjetContextHelper.print_context_param_errors(missing_methods)

        parameters
      end

      def find_context_params
        parameters = []
        missing_methods = []

        @context_class.method(:init).parameters.each do |param|
          param_value, missing_method_error = find_context_param(
            param[0], param[1]
          )

          parameters.push(param_value)

          if missing_method_error.present?
            missing_methods.push(missing_method_error)
          end
        end

        [parameters, missing_methods]
      end

      def find_context_param(type, method_name)
        send("find_#{type}_context_param", method_name)
      end

      def find_req_context_param(method_name)
        [send(method_name), nil]
      rescue StandardError => e
        [nil, { method_name => e.message }]
      end
      alias find_opt_context_param find_req_context_param

      def find_keyreq_context_param(method_name)
        [{ method_name => send(method_name) }, nil]
      rescue StandardError => e
        [{ method_name => nil }, { method_name => e.message }]
      end
      alias find_key_context_param find_keyreq_context_param

      def self.load
        Object.include(self)
      end

      class RailjetContextHelper
        def self.determine_context_class
          contexts_classes = Railjet::Context.descendants
          contexts_classes.each_with_index do |context_class, index|
            puts "(#{index + 1}) #{context_class}"
          end

          puts "\nPlease enter the number of needed railjet context"
          puts "(default: #{contexts_classes.first})"
          puts '-' * 61

          begin
            input = $stdin.gets.strip
            if input.present?
              chosen_index = Float(input)
              contexts_classes.fetch(chosen_index - 1)
            else
              contexts_classes[0]
            end
          rescue StandardError
            puts 'Invalid choice. Please try again.'
            retry
          end
        end

        def self.print_context_param_errors(missing_methods)
          return if missing_methods.empty?

          puts '!' * 61
          puts "\nError raised while finding context value(s) for methods below using `nil` instead"
          puts "To assign value simply define function(s) in console and it will be used the next time\n\n"
          missing_methods.each do |error|
            puts "\t- Method `#{error.keys.first}` => error: `#{error.values.first}`"
          end
          puts "\n"
          puts '!' * 61
        end
      end
    end
  end
end

