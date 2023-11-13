# frozen_string_literal: true

module Api
  module V1
    module ExternalProcessing
      module Payments
        module Create
          class DepositSerializer
            include JSONAPI::Serializer

            set_id :uuid
            set_type :deposit

            attributes :uuid, :card_number, :expiration_time, :national_currency, :national_currency_amount,
                       :payment_system, :initial_amount, :cryptocurrency_commission_amount,
                       :national_currency_commission_amount, :card_owner_name, :sbp_phone_number
            attribute :payment_link, -> { _1.payment_link.presence }
            attribute :payment_link_qr_code_url, -> { _1.payment_link_qr_code_url.presence }
            attribute :rate, -> { _1.rate_snapshot.value }
            attribute :commission_percentage, -> { _1.total_commission }
          end
        end
      end
    end
  end
end
