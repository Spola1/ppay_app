class AddIndexOnPaymentStatusToPayments < ActiveRecord::Migration[7.0]
  def change
    add_index :payments, :payment_status
    add_index :rate_snapshots, :direction
    add_index :payments, :advertisement_id
  end
end
