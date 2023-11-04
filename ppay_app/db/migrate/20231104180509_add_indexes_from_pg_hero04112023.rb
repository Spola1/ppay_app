class AddIndexesFromPgHero04112023 < ActiveRecord::Migration[7.0]
  def change
    commit_db_transaction
    add_index :advertisements, [:archived_at], algorithm: :concurrently
    add_index :payments, [:advertisement_id, :created_at], algorithm: :concurrently
    add_index :payments, [:arbitration, :created_at], algorithm: :concurrently
    add_index :transactions, [:to_balance_id, :created_at], algorithm: :concurrently
    add_index :transactions, [:unfreeze_time], algorithm: :concurrently
  end
end
