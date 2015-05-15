require_relative 'permits'
require_relative 'attribute'
require_relative 'typecaster'

module OffTheRecord

class ModelHandle
  def initialize(model)
    @model = model
    @permits = Permits.new
    @attributes = {}
    @typecasters = Typecaster.default_map.clone
  end
  attr_reader :model, :permits, :attributes, :typecasters

  def add_attribute(attribute)
    raise "Attribute named #{attribute.name.inspect} already exists" if
      attributes.key?(attribute.name)
    attributes[attribute.name] = attribute
    attribute.setup(self)
  end

  def apply_defaults(record)
    attributes.values.each do |attribute|
      if attribute.default_value? && !record.attributes.key?(attribute.name)
        record.attributes[attribute.name] = attribute.default_value
      end
    end
  end
end

end
