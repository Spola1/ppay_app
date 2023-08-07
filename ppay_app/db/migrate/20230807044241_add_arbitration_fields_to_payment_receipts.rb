class AddArbitrationFieldsToPaymentReceipts < ActiveRecord::Migration[7.0]
  def change
    add_column :payment_receipts, :start_arbitration, :boolean
    add_column :payment_receipts, :arbitration_source, :integer
  end
end
