module Api
  module V1
    class PaymentSerializer < ActiveModel::Serializer
      attributes :uuid, :url
    end
  end
end
