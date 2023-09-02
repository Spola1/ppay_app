class AddAdjustedRateToPayments < ActiveRecord::Migration[7.0]
  def change
    add_column :payments, :adjusted_rate, :decimal
  end
end
