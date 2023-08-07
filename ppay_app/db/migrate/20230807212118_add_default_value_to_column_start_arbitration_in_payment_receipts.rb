class AddDefaultValueToColumnStartArbitrationInPaymentReceipts < ActiveRecord::Migration[7.0]
  def change
    change_column :payment_receipts, :start_arbitration, :boolean, default: false, null: false
  end
end
