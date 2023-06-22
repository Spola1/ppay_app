class AddInitialAmountToPayments < ActiveRecord::Migration[7.0]
  def change
    add_column :payments, :initial_amount, :decimal, precision: 12, scale: 2
  end
end
