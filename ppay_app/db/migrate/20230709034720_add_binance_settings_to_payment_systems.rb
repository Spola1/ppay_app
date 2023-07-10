class AddBinanceSettingsToPaymentSystems < ActiveRecord::Migration[7.0]
  def change
    add_column :payment_systems, :binance_name, :string
    add_column :payment_systems, :ad_position_deposit, :integer, default: 10
    add_column :payment_systems, :ad_position_withdrawal, :integer, default: 5
    add_column :payment_systems, :trans_amount_deposit, :integer
    add_column :payment_systems, :trans_amount_withdrawal, :integer
    add_reference :payment_systems, :payment_system_copy, null: true, foreign_key: { to_table: :payment_systems }
  end
end
