# frozen_string_literal: true

class AddCryptocurrencyDefaultValueToPayments < ActiveRecord::Migration[7.0]
  def change
    Payment.update_all(cryptocurrency: 'USDT')
    change_column :payments, :cryptocurrency, :string, default: 'USDT', null: false
  end
end
