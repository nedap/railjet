module Railjet
  module Repository
    module ActiveRecordRepository
      extend ::ActiveSupport::Concern

      def find_by_ids(ids)
        query.where(id: ids)
      end

      def build(args = {}, &block)
        query.new(args, &block)
      end

      def duplicate(object, args = {})
        object.dup.tap do |new_object|
          new_object.assign_attributes(args) if args.present?
          yield(new_object)                  if block_given?
        end
      end

      def persist(object)
        object.save!
      end

      def destroy(object)
        object.destroy!
      end

      def transaction(&block)
        query.transaction(&block)
      end

      private

      def query_columns
        columns = (query.column_names - [:created_at, :updated_at])
        columns.map { |column_name| "#{query.table_name}.#{column_name}" }
      end
    end
  end
end
