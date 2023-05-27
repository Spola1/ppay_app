class CreateCommissions < ActiveRecord::Migration[7.0]
  def change
    create_table :commissions do |t|
      t.references :payment_system, null: false, foreign_key: true
      t.string :national_currency
      t.string :direction
      t.integer :commission_type
      t.decimal :commission, precision: 15, scale: 10
      t.references :merchant, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
