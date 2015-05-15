module OffTheRecord
  module Attribute

module QueryMethods
  module AttributeMethods
    def self.included(base)
      base.attribute_method_suffix '?'
    end

    def attribute?(attr)
      send(attr).present?
    end
  end

  def self.attribute_methods
    AttributeMethods
  end
end

  end
end

