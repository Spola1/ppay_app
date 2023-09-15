class AddTransactionHashToBalanceRequest < ActiveRecord::Migration[7.0]
  def change
    add_column :balance_requests, :transaction_hash, :string
  end
end
