# frozen_string_literal: true

module Api
  module V1
    module ExternalProcessing
      module Payments
        module Create
          class WithdrawalSerializer
            include JSONAPI::Serializer

            set_id :uuid
            set_type :withdrawal

            attributes :uuid, :national_currency, :national_currency_amount, :payment_system, :initial_amount,
                       :cryptocurrency_commission_amount, :national_currency_commission_amount
          end
        end
      end
    end
  end
end
