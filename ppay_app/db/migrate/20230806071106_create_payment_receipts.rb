class CreatePaymentReceipts < ActiveRecord::Migration[6.1]
  def change
    create_table :payment_receipts do |t|
      t.string :image
      t.string :comment
      t.references :payment, null: false, foreign_key: true

      t.timestamps
    end
  end
end