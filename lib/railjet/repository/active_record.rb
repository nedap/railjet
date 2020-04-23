require_relative "generic"

module Railjet
  module Repository
    class ActiveRecord < Generic
      self.type = :record

      module RepositoryMethods
        def all
          record.all
        end

        def find_by_id(id)
          record.find(id)
        end

        def find_by_ids(ids)
          record.where(id: ids)
        end

        def build(args = {}, &block)
          record.new(args, &block)
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
          record.transaction(&block)
        end

        private

        def query_columns
          columns = (record.column_names - [:created_at, :updated_at])
          columns.map { |column_name| "#{record.table_name}.#{column_name}" }
        end
      end
    end
  end
end
