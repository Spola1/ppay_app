class AddTransactionTypeToTransactions < ActiveRecord::Migration[7.0]
  def change
    add_column :transactions, :transaction_type, :integer, null: false, default: 0
  end
end
