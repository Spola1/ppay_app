class CreatePaymentLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :payment_logs do |t|
      t.text :banks_response
      t.text :create_order_response
      t.text :payinfo_responses
      t.string :other_processing_id

      t.references :payment, foreign_key: { to_table: :payments }, index: true

      t.timestamps
    end
  end
end
