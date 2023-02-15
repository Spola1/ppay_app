# frozen_string_literal: true

module Api
  module V1
    module Payments
      module Show
        class BaseSerializer
          include JSONAPI::Serializer

          attribute :uuid
          attribute :external_order_id, if: proc { |record| record.external_order_id.present? }
          attributes :created_at, :national_currency, :national_currency_amount,
                     :cryptocurrency, :payment_system, :payment_status
        end
      end
    end
  end
end
