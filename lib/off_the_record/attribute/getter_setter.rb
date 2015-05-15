module OffTheRecord
  module Attribute

module GetterSetter
  module AttributeMethods
    def self.included(base)
      base.attribute_method_affix
      base.attribute_method_suffix '='
    end

    def attribute(attr)
      attributes[attr]
    end

    def attribute=(attr, value)
      attributes[attr] = value
    end
  end

  def self.attribute_methods
    AttributeMethods
  end
end

  end
end


