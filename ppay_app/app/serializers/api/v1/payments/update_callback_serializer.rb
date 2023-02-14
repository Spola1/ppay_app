# frozen_string_literal: true

module Api
  module V1
    module Payments
      class UpdateCallbackSerializer
        include JSONAPI::Serializer

        attribute :uuid
        attribute :external_order_id, if: proc { |record| record.external_order_id.present? }
        attribute :payment_status
      end
    end
  end
end
