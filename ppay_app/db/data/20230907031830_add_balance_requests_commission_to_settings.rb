# frozen_string_literal: true

class AddBalanceRequestsCommissionToSettings < ActiveRecord::Migration[7.0]
  def up
    Setting.instance.update(balance_requests_commission: 3)
  end
end
