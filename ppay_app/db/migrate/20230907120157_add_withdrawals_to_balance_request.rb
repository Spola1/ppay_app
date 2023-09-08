class AddWithdrawalsToBalanceRequest < ActiveRecord::Migration[7.0]
  def change
    add_column :balance_requests, :amount_minus_commission, :decimal, precision: 128, scale: 64
    add_column :balance_requests, :real_commission, :decimal, precision: 128, scale: 64
  end
end
