class CreatePaymentLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :payment_logs do |t|
      t.text :banks_response
      t.text :create_order_response
      t.text :payinfo_responses
      t.string :other_processing_id

      t.timestamps
    end
  end
end
