class AddReasonToPaymentReceipts < ActiveRecord::Migration[7.0]
  def change
    add_column :payment_receipts, :receipt_reason, :integer
  end
end
