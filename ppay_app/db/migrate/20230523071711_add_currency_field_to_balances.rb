class AddCurrencyFieldToBalances < ActiveRecord::Migration[7.0]
  def change
    add_column :balances, :currency, :string, default: 'USDT'
  end
end
