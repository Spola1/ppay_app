class AddUsersToPaymentReceipts < ActiveRecord::Migration[7.0]
  def change
    add_reference :payment_receipts, :user, foreign_key: true
  end
end
