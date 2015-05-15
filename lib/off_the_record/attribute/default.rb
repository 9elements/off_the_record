module OffTheRecord
  module Attribute

module Default
  module Descriptor
    def default_value?
      @defaulted
    end

    attr_reader :default_value

    def handle_options(options)
      @defaulted = true if @default_value = options.delete(:default)
      super
    end
  end

  def self.descriptor_module
    Descriptor
  end
end

  end
end



