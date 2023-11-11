# frozen_string_literal: true

module Api
  module V1
    class MerchantMethodSerializer
      include JSONAPI::Serializer

      set_id :id
      set_type :merchant_method

      attribute :id, :direction, :payment_system_name, :currency, :rate, :commission_percentage
    end
  end
end
