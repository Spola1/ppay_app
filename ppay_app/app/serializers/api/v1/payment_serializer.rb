# frozen_string_literal: true

module Api
  module V1
    class PaymentSerializer < ActiveModel::Serializer
      attributes :uuid
      attribute  :external_order_id, if: -> { object&.external_order_id.present? }
      attributes :created_at, :type,
                 :national_currency, :national_currency_amount,
                 :cryptocurrency, :payment_system, :payment_status

      def national_currency_amount
        object.national_currency_amount.to_f
      end
    end
  end
end
