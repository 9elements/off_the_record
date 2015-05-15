module OffTheRecord
  module Attribute

class Descriptor
  def initialize(name, options)
    @name = name
    handle_options(options)
    raise "Unknown options: #{options.keys.inspect}" unless options.empty?
    freeze
  end
  attr_reader :name

  def setup(model_handle)
    model_handle.permits.add_filters permit_filters
    model_handle.model.define_attribute_methods name
  end

  module BaseBehaviour
    private

    def handle_options(options)
    end
  end
  include BaseBehaviour

  Attribute.features.each do |feature|
    include feature.descriptor_module if feature.respond_to?(:descriptor_module)
  end

  def permit_filters
    [name]
  end
end

  end
end

