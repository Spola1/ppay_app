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
          attribute :payment_status
        end
      end
    end
  end
end
