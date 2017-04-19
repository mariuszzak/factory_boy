require "factory_boy/version"

module FactoryBoy
  SchemaNotDefined = Class.new(StandardError)
  @factories = {}

  class << self
    attr_accessor :factories

    def reset_factories
      self.factories = {}
    end

    def define_factory(klass)
      factories[klass] = true
    end

    def build(klass, **attrs)
      raise SchemaNotDefined unless factories[klass]
      klass.new.tap do |instance|
        attrs.each do |key, val|
          instance.public_send("#{key}=", val)
        end
      end
    end
  end
end
