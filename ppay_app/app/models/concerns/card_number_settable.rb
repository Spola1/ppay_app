# frozen_string_literal: true

module CardNumberSettable
  extend ActiveSupport::Concern

  included do
    def card_number=(value)
      super(value&.gsub(%r{[^\w\d/]}, ''))
    end
  end
end
