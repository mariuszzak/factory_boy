require 'factory_boy/default_values_builder'

module FactoryBoy
  class InstanceFactory
    attr_reader :default_values

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
      @default_values = default_values_builder.instance_eval('@default_values')
    end

    def klass
      target_schema = optional_klass || schema
      case target_schema
        when Symbol then Object.const_get(target_schema.capitalize)
        when Class then target_schema
        else raise SchemaNotSupported
      end
    end
  end
end
