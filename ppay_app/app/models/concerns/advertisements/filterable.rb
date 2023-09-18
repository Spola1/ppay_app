# frozen_string_literal: true

module Advertisements
  module Filterable
    extend ActiveSupport::Concern

    included do
      scope :filter_by_status,      ->(status) { where(status:) }
      scope :filter_by_card_number, ->(card_number) { where("card_number ilike ?", "%#{card_number}%") }
      scope :filter_by_direction,         ->(direction) { where(direction:) }
      scope :filter_by_national_currency, ->(national_currency) { where(national_currency:) }
      scope :filter_by_payment_system,    ->(payment_system) { where(payment_system:) }
      scope :filter_by_processer,         ->(processer) { where(processer:) }
    end
  end
end
