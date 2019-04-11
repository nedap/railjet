require "active_support/concern"

module Railjet
  module Presenter
    extend ActiveSupport::Concern

    def initialize(object)
      @object = object
    end

    def as_json(*)
      raise NotImplementedError
    end

    module ClassMethods
      def present_collection(objects)
        objects.map { |o| new(o) }
      end

      private

      def present(name)
        define_method(name) { instance_variable_get(:@object) }
        private name
      end
    end

    module WithContext
      extend ActiveSupport::Concern

      included do
        attr_reader :context
        private     :context
      end

      def initialize(context, object)
        @context = context
        super(object)
      end

      module ClassMethods
        def present_collection(context, objects)
          objects.map { |o| new(context, o) }
        end
      end

      module Factory
        extend ActiveSupport::Concern

        module ClassMethods
          def present_collection(context, objects)
            objects.map { |o| present(context, o) }
          end

          def present(context, object)
            presenter_class(object).new(context, object)
          end

          def presenter_class(object)
            raise NotImplementedError
          end
        end
      end
    end

    module Factory
      extend ActiveSupport::Concern

      module ClassMethods
        def present_collection(objects)
          objects.map { |o| present(o) }
        end

        def present(object)
          presenter_class(object).new(object)
        end

        def presenter_class(object)
          raise NotImplementedError
        end
      end
    end
  end
end
