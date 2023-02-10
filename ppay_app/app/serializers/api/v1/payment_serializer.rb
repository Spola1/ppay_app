# frozen_string_literal: true

module Api
  module V1
    class PaymentSerializer < ActiveModel::Serializer
      attributes :uuid
      attribute  :external_order_id, if: -> { object&.external_order_id.present? }
      attributes :created_at, :type,
                 :national_currency, :national_currency_amount,
                 :cryptocurrency, :payment_system, :payment_status
    end
  end
end
