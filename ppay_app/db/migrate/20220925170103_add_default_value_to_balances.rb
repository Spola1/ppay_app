class AddDefaultValueToBalances < ActiveRecord::Migration[7.0]
  def change
    change_column :balances, :amount, :decimal, null: false, default: 0
  end
end
