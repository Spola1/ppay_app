class PaymentCallbacks < ActiveRecord::Migration[7.0]
  def change
    create_table :payment_callbacks do |t|
      t.references :payment, foreign_key: true
      t.datetime :response_at 
      t.string :response_status
      t.text :response_body
      t.text :request

      t.timestamps
    end
  end
end
