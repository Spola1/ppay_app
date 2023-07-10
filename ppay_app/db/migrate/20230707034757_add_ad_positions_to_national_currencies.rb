class AddAdPositionsToNationalCurrencies < ActiveRecord::Migration[7.0]
  def change
    add_column :national_currencies, :ad_position_deposit, :integer, default: 10
    add_column :national_currencies, :ad_position_withdrawal, :integer, default: 5
  end
end
