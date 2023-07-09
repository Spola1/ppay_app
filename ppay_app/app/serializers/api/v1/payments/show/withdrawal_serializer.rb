# frozen_string_literal: true

module Api
  module V1
    module Payments
      module Show
        class WithdrawalSerializer < BaseSerializer
          set_type :withdrawal
        end
      end
    end
  end
end
