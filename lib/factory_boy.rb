require "factory_boy/version"

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
        factory.default_values.merge(attrs).each do |key, val|
          raise InvalidAttributes.new("#{key} attribute is wrong") unless instance.respond_to?("#{key}=")
          instance.public_send("#{key}=", val)
        end
      end
    end

    private

    attr_accessor :factories

    def validate_schema(schema)
      raise SchemaNotSupported unless SUPPORTED_SCHEMA_TYPES.include?(schema.class)
    end
  end

  class InstanceFactory
    attr_accessor :default_values

    def initialize(schema, optional_klass, &block)
      @schema         = schema
      @optional_klass = optional_klass
      @default_values = {}
      build_default_values(&block) if block_given?
    end

    def build
      klass.new
    end

    private

    attr_accessor :schema, :optional_klass

    def build_default_values(&block)
      default_values_builder = DefaultValuesBuilder.new
      default_values_builder.instance_eval(&block)
      @default_values = default_values_builder.instance_eval("@default_values")
    end

    def klass
      target_schema = optional_klass || schema
      case schema
        when Symbol then Object.const_get(target_schema.capitalize)
        when Class then target_schema
        else raise SchemaNotSupported
      end
    end

    class DefaultValuesBuilder
      def initialize
        @default_values = {}
      end

      def method_missing(method_name, *args)
        if !args.empty?
          @default_values[method_name] = args.first
        else
          super
        end
      end
    end
  end
end
