class CreatePaymentWays < ActiveRecord::Migration[7.0]
  def change
    create_table :payment_ways do |t|
      t.references :payment_system, null: false, foreign_key: true
      t.references :national_currency, null: false, foreign_key: true

      t.timestamps
    end
  end
end
