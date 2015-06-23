module OffTheRecord
  module Attribute

module Typecasted
  module AttributeMethods
    def self.included(base)
      base.attribute_method_suffix "_before_type_cast"
    end

    def attribute_before_type_cast(attr)
      attribute(attr, false)
    end

    def attribute(attr, typecasting = true)
      if typecasting
        handle = self.class.off_the_record_handle
        type = handle.attributes[attr].type
        typecaster = handle.typecasters.merge(nil => ->(v){v}).fetch(type) { raise "No typecaster for type #{type.inspect}" }
        value = super(attr)
        typecaster.call(value) unless nil.equal?(value)
      else
        super(attr)
      end
    end
  end

  def self.attribute_methods
    AttributeMethods
  end

  module DescriptorModule
    attr_reader :type

    def handle_options(options)
      @type = options.delete(:type)

      super
    end
  end

  def self.descriptor_module
    DescriptorModule
  end
end

  end
end


