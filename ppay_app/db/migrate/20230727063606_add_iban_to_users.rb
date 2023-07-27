class AddIbanToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :iban, :string
  end
end
