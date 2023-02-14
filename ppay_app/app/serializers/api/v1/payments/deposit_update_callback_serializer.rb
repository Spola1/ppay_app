# frozen_string_literal: true

module Api
  module V1
    module Payments
      class DepositUpdateCallbackSerializer < UpdateCallbackSerializer
        set_type :Deposit
      end
    end
  end
end
