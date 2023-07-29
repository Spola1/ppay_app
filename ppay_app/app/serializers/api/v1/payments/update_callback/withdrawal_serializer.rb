# frozen_string_literal: true

module Api
  module V1
    module Payments
      module UpdateCallback
        class WithdrawalSerializer < BaseSerializer
          set_type :withdrawal
        end
      end
    end
  end
end
