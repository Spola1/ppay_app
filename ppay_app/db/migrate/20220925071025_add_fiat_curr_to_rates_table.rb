class AddFiatCurrToRatesTable < ActiveRecord::Migration[7.0]
  def change
  	# добавим нац валюту - к курсу
    add_column :rate_snapshots, :national_currency, :string
    # добавим кол-во валюты
    add_column :rate_snapshots, :adv_amount, :decimal
  end
end
