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

    def attribute(name, options = {})
      attr = Attribute::Descriptor.new(name.to_s, options)
      off_the_record_handle.add_attribute(attr)
      return attr
    end
  end

  def initialize(params = nil)
    params = sanitize_for_mass_assignment(params)
    super(params)
    self.class.off_the_record_handle.apply_defaults(self)
  end

  def attributes
    @attributes ||= ActiveSupport::HashWithIndifferentAccess.new
  end

  include(*Attribute.features)
end

end
