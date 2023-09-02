class ChangeBinanceNameToExchangeNameForPaymentSystems < ActiveRecord::Migration[7.0]
  def change
    rename_column :payment_systems, :binance_name, :exchange_name
  end
end
