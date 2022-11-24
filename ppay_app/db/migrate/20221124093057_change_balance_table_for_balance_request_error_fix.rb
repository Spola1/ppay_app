class ChangeBalanceTableForBalanceRequestErrorFix < ActiveRecord::Migration[7.0]
  def change
    change_column :transactions, :from_balance_id, :bigint, null: true, default: 0
    change_column :transactions, :to_balance_id, :bigint, null: true, default: 0
  end
end
