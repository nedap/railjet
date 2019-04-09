module Railjet
  class Context
    def initialize(**kwargs)
      define_accessors(kwargs)
    end

    # New values can be assigned to context on-the-fly,
    # but it's not possible to change anything.
    def method_missing(name, *args, &block)
      getter_name = name[0..-2]

      if name =~ /^[a-z]+=$/ && !respond_to?(getter_name)
        define_accessor(getter_name, args.first)
      else
        super
      end
    end

    private

    def define_accessors(kwargs)
      kwargs.each do |name, val|
        define_accessor(name, val)
      end
    end

    def define_accessor(name, value)
      instance_variable_set("@#{name}", value)
      define_singleton_method(name) { instance_variable_get(:"@#{name}") }
    end
  end
end
