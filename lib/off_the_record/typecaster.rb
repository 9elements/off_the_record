module OffTheRecord

module Typecaster
  module BooleanCaster
    # Taken from the active_attr gem

    FALSE_VALUES = ["n", "N", "no", "No", "NO", "false", "False", "FALSE", "off", "Off", "OFF", "f", "F"]

    def self.call(value)
      case value
      when *FALSE_VALUES then false
      when Numeric, /^\-?[0-9]/ then !value.to_f.zero?
      else value.present?
      end
    end
  end

  Boolean = Module.new

  DEFAULT_CASTERS = {
    Boolean  => BooleanCaster.method(:call),
    Date     => ->(v) { rescuing(ArgumentError) { v.try(:to_date) } },
    DateTime => ->(v) { rescuing(ArgumentError) { v.try(:to_datetime) } },
    Float    => ->(v) { rescuing(ArgumentError) { Float(v) } },
    Integer  => ->(v) { rescuing(ArgumentError) { Integer(v) } },
    String   => ->(v) { v.try(:to_s) },
  }.tap do |table|
    table[:bool] = table[:boolean] = table[Boolean]

    table.keys.each do |key|
      next unless key.is_a?(Module)
      next if key.name.include?('::')

      name = key.name.underscore
      table[name] = table[name.to_sym] = table[key]
    end
  end

  def self.rescuing(*exception_classes)
    yield
  rescue *exception_classes
  end

  def self.default_map
    DEFAULT_CASTERS
  end
end

end

