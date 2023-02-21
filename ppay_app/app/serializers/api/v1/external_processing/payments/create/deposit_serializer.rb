# frozen_string_literal: true

module Api
  module V1
    module ExternalProcessing
      module Payments
        module Create
          class DepositSerializer
            include JSONAPI::Serializer

            set_id :uuid

            attributes :uuid, :card_number, :expiration_time
          end
        end
      end
    end
  end
end
