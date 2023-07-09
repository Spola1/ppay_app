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
                       :initial_amount, :cryptocurrency_commission_amount, :national_currency_commission_amount
            attribute :payment_link, if: proc { _1.payment_link.present? }
            attribute :payment_link_qr_code_url, if: proc { _1.payment_link_qr_code_url.present? }
          end
        end
      end
    end
  end
end
