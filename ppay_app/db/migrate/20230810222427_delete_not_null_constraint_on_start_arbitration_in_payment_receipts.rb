class DeleteNotNullConstraintOnStartArbitrationInPaymentReceipts < ActiveRecord::Migration[7.0]
  def up
    change_column :payment_receipts, :start_arbitration, :boolean, default: false, null: true
  end

  def down
    change_column :payment_receipts, :start_arbitration, :boolean, default: false, null: false
  end
end
