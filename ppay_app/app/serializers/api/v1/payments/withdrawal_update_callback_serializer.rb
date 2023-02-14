# frozen_string_literal: true

module Api
  module V1
    module Payments
      class WithdrawalUpdateCallbackSerializer < UpdateCallbackSerializer
        set_type :Withdrawal
      end
    end
  end
end
