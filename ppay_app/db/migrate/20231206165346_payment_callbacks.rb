class PaymentCallbacks < ActiveRecord::Migration[7.0]
  def change
    create_table :payment_callbacks do |t|
      t.references :payment, foreign_key: true
      t.datetime :sent_at
      t.datetime :received_at
      t.string :status
      t.text :response_body

      t.timestamps
    end
  end
end
