# frozen_string_literal: true

module Api
  module V1
    module Payments
      module Show
        class BaseSerializer
          include JSONAPI::Serializer

          set_id :uuid

          attribute :uuid
          attribute :external_order_id, if: proc { |record| record.external_order_id.present? }
          attribute :cancellation_reason, if: proc { |record| record.cancellation_reason.present? }
          attributes :created_at, :national_currency, :national_currency_amount, :initial_amount,
                     :cryptocurrency, :payment_system, :payment_status, :cryptocurrency_commission_amount,
                     :national_currency_commission_amount, :arbitration, :arbitration_reason
        end
      end
    end
  end
end
