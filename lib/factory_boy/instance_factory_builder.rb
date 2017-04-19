module FactoryBoy
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
