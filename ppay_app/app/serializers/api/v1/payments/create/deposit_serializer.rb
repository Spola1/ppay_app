# frozen_string_literal: true

module Api
  module V1
    module Payments
      module Create
        class DepositSerializer < BaseSerializer
          set_type :deposit
        end
      end
    end
  end
end
