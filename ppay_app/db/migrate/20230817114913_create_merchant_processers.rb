class CreateMerchantProcessers < ActiveRecord::Migration[7.0]
  def change
    create_table :merchant_processers do |t|
      t.references :merchant, null: false, foreign_key: { to_table: :users }
      t.references :processer, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
