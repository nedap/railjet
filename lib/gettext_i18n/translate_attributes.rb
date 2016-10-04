module GettextI18n
  module TranslateAttributes
    def self.store_form_attributes(file: "locale/form_attributes.rb")
      store_attributes(file, FormAttributesFinder.new)
    end

    def self.store_policy_attributes(file: "locale/policy_attributes.rb")
      store_attributes(file, PolicyAttributesFinder.new)
    end

    private

    def self.store_attributes(file, finder)
      File.open(file, 'w') do |f|
        f.puts "# DO NOT MODIFY! AUTOMATICALLY GENERATED FILE!"

        finder.find.each do |object, attributes|
          f.puts("_('#{object.humanize_class_name}')")

          attributes.each do |attribute|
            translation = object.gettext_translation_for_attribute_name(attribute)
            f.puts("_('#{translation}')")
          end
        end

        f.puts "# DO NOT MODIFY! AUTOMATICALLY GENERATED FILE!"
      end
    rescue
      puts "[Error] Attribute extraction failed. Removing incomplete file (#{file})"

      File.delete(file)
      raise
    end

    class AttributeFinder
      def find
        ActiveSupport::OrderedHash.new([]).tap do |found|
          objects.each do |object|
            found[object] = attributes(object)
          end
        end
      end

      private

      def objects
        @objects ||= ObjectSpace.each_object(Class).select do |c|
          c.included_modules.include?(base_class)
        end
      end

      def attributes(object)
        object.attribute_set.map(&:name).sort
      end

      def base_class
        raise NotImplementedError
      end
    end

    class PolicyAttributesFinder < AttributeFinder
      def base_class
        OnsContext::Policy
      end
    end

    class FormAttributesFinder < AttributeFinder
      def base_class
        OnsContext::Form
      end
    end
  end
end
