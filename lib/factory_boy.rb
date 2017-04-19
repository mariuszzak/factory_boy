require "factory_boy/version"

module FactoryBoy
  SchemaNotDefined   = Class.new(StandardError)
  InvalidAttributes  = Class.new(StandardError)
  SchemaNotSupported = Class.new(StandardError)
  @factories = {}

  SUPPORTED_SCHEMA_TYPES = [Symbol, Class].freeze

  class << self
    attr_accessor :factories

    def reset_factories
      self.factories = {}
    end

    def define_factory(schema, &block)
      validate_schema(schema)
      factories[schema] = InstanceFactory.new(schema, &block)
    end

    def validate_schema(schema)
      raise SchemaNotSupported unless SUPPORTED_SCHEMA_TYPES.include?(schema.class)
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
  end

  class InstanceFactory
    attr_accessor :schema, :default_values

    def initialize(schema, &block)
      @schema         = schema
      @default_values = {}
      instance_eval &block if block_given?
    end

    def build
      klass.new
    end

    def klass
      case schema
        when Symbol then Object.const_get(schema.capitalize)
        when Class then schema
        else raise SchemaNotSupported
      end
    end

    def method_missing(method_name, *args)
      if !args.empty?
        default_values[method_name] = args.first
      else
        super
      end
    end
  end
end
