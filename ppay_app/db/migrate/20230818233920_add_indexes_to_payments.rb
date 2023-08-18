class AddIndexesToPayments < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_index :payments, :arbitration_reason, algorithm: :concurrently
    add_index :payments, :created_at, algorithm: :concurrently
    add_index :payments, :status_changed_at, algorithm: :concurrently
    add_index :payments, :uuid, algorithm: :concurrently
    add_index :transactions, %i[from_balance_id transaction_type], algorithm: :concurrently
  end
end
