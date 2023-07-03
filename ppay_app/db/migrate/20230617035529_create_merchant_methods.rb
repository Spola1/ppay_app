class CreateMerchantMethods < ActiveRecord::Migration[7.0]
  def change
    create_table :merchant_methods do |t|
      t.references :merchant, null: false, foreign_key: { to_table: :users }
      t.references :payment_system, null: false, foreign_key: true
      t.string :direction

      t.timestamps
    end
  end
end
