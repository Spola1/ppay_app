# frozen_string_literal: true

module MerchantMethods
  module Filterable
    extend ActiveSupport::Concern

    included do
      scope :filter_by_payment_system, ->(payment_system) {
        joins(:payment_system).where(payment_systems: { name: payment_system })
      }

      scope :filter_by_national_currency, ->(national_currency) {
        joins(payment_system: :national_currency)
          .where(national_currencies: { name: national_currency })
      }
    end
  end
end
