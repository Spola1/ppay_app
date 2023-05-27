class CreatePaymentSystems < ActiveRecord::Migration[7.0]
  def change
    create_table :payment_systems do |t|
      t.string :name

      t.timestamps
    end
  end
end
