class AddNationalCurrencyAmountFieldToTransactions < ActiveRecord::Migration[7.0]
  def change
    add_column :transactions, :national_currency_amount, :decimal, precision: 12, scale: 2
  end
end
