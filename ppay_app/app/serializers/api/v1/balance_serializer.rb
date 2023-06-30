# frozen_string_literal: true

module Api
  module V1
    class BalanceSerializer
      include JSONAPI::Serializer

      set_id :id
      set_type :balance

      attribute :id, -> { _1.id.to_s }
      attributes :amount, :currency
    end
  end
end
