module Api
  module V1
    module Payments
      class WithdrawalSerializer < PaymentSerializer
        type :withdrawal
      end
    end
  end
end
