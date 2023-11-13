# frozen_string_literal: true

module Api
  module V1
    class MerchantMethodSerializer
      include JSONAPI::Serializer

      set_id :id
      set_type :merchant_method

      attributes :direction
      attribute :payment_system, -> { _1.payment_system.name }
      attribute :national_currency, -> { _1.national_currency.name }
      attributes :rate, :commission_percentage
    end
  end
end
