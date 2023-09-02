class AddExtraPercentToPaymentSystems < ActiveRecord::Migration[7.0]
  def change
    add_column :payment_systems, :extra_percent_deposit, :decimal, precision: 15, scale: 10, default: 0
    add_column :payment_systems, :extra_percent_withdrawal, :decimal, precision: 15, scale: 10, default: 0
  end
end
