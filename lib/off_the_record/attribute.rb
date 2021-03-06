require_relative 'attribute/getter_setter'
require_relative 'attribute/query_methods'
require_relative 'attribute/default'
require_relative 'attribute/typecasted'

module OffTheRecord
  module Attribute

    def self.features
      [
        Default,
        GetterSetter,
        QueryMethods,
        Typecasted
      ]
    end

  end
end


