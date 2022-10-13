module Api
  module V1
    module Payments
      class DepositSerializer < PaymentSerializer
        type :deposit
      end
    end
  end
end
