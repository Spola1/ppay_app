# frozen_string_literal: true

module Api
  module V1
    module ExternalProcessing
      module Payments
        module PaymentReceipts
          module Create
            class PaymentReceiptSerializer
              include JSONAPI::Serializer

              attributes :image_url, :comment, :receipt_reason, :start_arbitration, :source
            end
          end
        end
      end
    end
  end
end
