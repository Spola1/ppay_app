class AddUniqueAmountToPayments < ActiveRecord::Migration[7.0]
  def change
    add_column :payments, :unique_amount, :integer, default: 0
  end
end
