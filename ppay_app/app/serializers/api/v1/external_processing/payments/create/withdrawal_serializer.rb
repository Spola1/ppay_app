# frozen_string_literal: true

module Api
  module V1
    module ExternalProcessing
      module Payments
        module Create
          class WithdrawalSerializer
            include JSONAPI::Serializer

            set_id :uuid
            set_type :Withdrawal

            attributes :uuid
          end
        end
      end
    end
  end
end
