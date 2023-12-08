# frozen_string_literal: true

module Api
  module V1
    module Payments
      module UpdateCallback
        class BaseSerializer
          include JSONAPI::Serializer

          set_id :uuid

          attribute :uuid
          attribute :external_order_id, if: proc { |record| record.external_order_id.present? }
          attribute :cancellation_reason, if: proc { |record| record.cancellation_reason.present? }
          attribute :payment_status
          attribute :national_currency_amount
          attribute :initial_amount
          attribute :national_currency
          attribute :cryptocurrency_commission_amount
          attribute :national_currency_commission_amount
          attribute :arbitration
          attribute :arbitration_reason
          attribute :rate, -> { _1.rate_snapshot&.value }
          attribute :commission_percentage, -> { _1.total_commission }
          attribute :sbp_bank
        end
      end
    end
  end
end
