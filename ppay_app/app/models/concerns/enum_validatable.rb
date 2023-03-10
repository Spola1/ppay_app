# frozen_string_literal: true

# ActiveRecord::Enum validation in Rails API
# https://medium.com/nerd-for-tech/using-activerecord-enum-in-rails-35edc2e9070f
module EnumValidatable
  extend ActiveSupport::Concern

  class_methods do
    def validatable_enum(*enums_to_fix)
      enums_to_fix.each do |element|
        attribute(element) do |subtype|
          subtype = subtype.subtype if subtype.is_a?(ActiveRecord::Enum::EnumType)
          ValidatableEnumType.new(element, defined_enums.fetch(element.to_s), subtype)
        end
      end
    end
  end

  class ValidatableEnumType < ActiveRecord::Enum::EnumType
    # override assert_valid_value() to supress <ArgumentError>
    # return a value and depend on our own validation
    def assert_valid_value(value)
      value
    end
  end
end
