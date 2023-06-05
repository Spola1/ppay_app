class AddLocaleToPayments < ActiveRecord::Migration[7.0]
  def change
    add_column :payments, :locale, :string
  end
end
