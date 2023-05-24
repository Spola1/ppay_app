class AddInNationalCurrencyFieldToBalances < ActiveRecord::Migration[7.0]
  def change
    add_column :balances, :in_national_currency, :boolean, default: false
  end
end
