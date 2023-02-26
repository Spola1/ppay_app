# frozen_string_literal: true

module Api
  module V1
    module ExternalProcessing
      module Payments
        module Create
          class DepositSerializer
            include JSONAPI::Serializer

            set_id :uuid
            set_type :Deposit

            attributes :uuid, :card_number, :expiration_time
          end
        end
      end
    end
  end
end
