module OffTheRecord
  module Attribute

module Default
  module AttributeMethods
    def self.included(base)
      base.attribute_method_affix
    end

    def attribute(attr)
      self.class.off_the_record_handle.attributes[attr].default_value
    end
  end

  def self.attribute_methods
    AttributeMethods
  end

  module Descriptor
    attr_reader :default_value

    def handle_options(options)
      @default_value = options.delete(:default)
      super
    end
  end

  def self.descriptor_module
    Descriptor
  end
end

  end
end



