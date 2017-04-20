require 'factory_boy/version'
require 'factory_boy/instance_factory'

module FactoryBoy
  SchemaNotDefined     = Class.new(StandardError)
  InvalidAttributes    = Class.new(StandardError)
  SchemaNotSupported   = Class.new(StandardError)
  InvalidOptionalClass = Class.new(StandardError)

  SUPPORTED_SCHEMA_TYPES = [Symbol, Class].freeze

  @factories = {}

  class << self
    def reset_factories
      self.factories = {}
    end

    def define_factory(schema, **opts, &block)
      validate_schema(schema)
      optional_klass = opts[:class]
      raise InvalidOptionalClass if optional_klass && !optional_klass.is_a?(Class)
      factories[schema] = InstanceFactory.new(schema, optional_klass, &block)
    end

    def build(schema, **attrs)
      factory = factories[schema]
      raise SchemaNotDefined unless factory
      factory.build.tap do |instance|
        set_instance_attributes(instance, factory.default_values.merge(attrs))
      end
    end

    private

    attr_accessor :factories

    def validate_schema(schema)
      raise SchemaNotSupported unless SUPPORTED_SCHEMA_TYPES.include?(schema.class)
    end

    def set_instance_attributes(instance, attrs)
      attrs.each do |attr_name, val|
        raise InvalidAttributes.new("#{attr_name} attribute is wrong") unless instance.respond_to?("#{attr_name}=")
        instance.public_send("#{attr_name}=", val)
      end
    end
  end
end
