require 'active_model'

require_relative 'model_handle'
require_relative 'attribute'
require_relative 'attribute/descriptor'

module OffTheRecord

class Base
  include ActiveModel::Model
  include ActiveModel::ForbiddenAttributesProtection
  include ActiveModel::AttributeMethods

  Attribute.features.each do |feature|
    include feature.attribute_methods if feature.respond_to?(:attribute_methods)
  end

  class << self
    def off_the_record_handle
      @off_the_record_handle ||= ModelHandle.new(self)
    end

    def inherited(model)
      inherits_from_model = model.ancestors.drop(1).grep(Class).first != Base
      if inherits_from_model
        # we could support this, but it would mean changing things all over.
        raise "Inheriting from a model which inherits from OffTheRecord::Model is not supported"
      end
    end

    def permit(*filters)
      off_the_record_handle.permits.add_filters(filters)
      self
    end

    def permit_filters
      off_the_record_handle.permits.to_permit_filters
    end

    def from_params(params)
      new.assign_from_params(params)
    end

    def from_optional_params(params)
      new.assign_from_optional_params(params)
    end

    def attribute(name, options = {})
      attr = Attribute::Descriptor.new(name.to_s, options)
      off_the_record_handle.add_attribute(attr)
      return attr
    end

    def model_name
      @model_name ||= ActiveModel::Name.new(self, nil, model_name_base)
    end

    def model_name_base
      name.demodulize
    end
  end

  # DEPRECATED to use this method with attributes
  def initialize(attributes = nil)
    attributes = sanitize_for_mass_assignment(attributes)
    super(attributes)
  end

  def assign_attributes(attributes = nil)
    attributes = sanitize_for_mass_assignment(attributes)
    attributes.each do |attr, value|
      self.public_send("#{attr}=", value)
    end if attributes
  end

  def assign_from_params(params)
    assign_attributes(
      params
        .require(self.class.model_name.param_key)
        .permit(*self.class.permit_filters))
    self
  end

  def assign_from_optional_params(params)
    if params.key?(self.class.model_name.param_key)
      assign_from_params(params)
    end
    self
  end

  def attributes
    @attributes ||= ActiveSupport::HashWithIndifferentAccess.new
  end

  include(*Attribute.features)
end

end
