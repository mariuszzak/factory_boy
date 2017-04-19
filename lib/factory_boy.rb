require "factory_boy/version"

module FactoryBoy
  SchemaNotDefined  = Class.new(StandardError)
  InvalidAttributes = Class.new(StandardError)
  @factories = {}

  class << self
    attr_accessor :factories

    def reset_factories
      self.factories = {}
    end

    def define_factory(klass, &block)
      factories[klass] = InstanceFactory.new(klass, &block)
    end

    def build(klass, **attrs)
      factory = factories[klass]
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
    attr_accessor :klass, :default_values

    def initialize(klass, &block)
      @klass          = klass
      @default_values = {}
      instance_eval &block if block_given?
    end

    def build
      klass.new
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
