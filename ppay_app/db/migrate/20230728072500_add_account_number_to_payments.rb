class AddAccountNumberToPayments < ActiveRecord::Migration[7.0]
  def change
    add_column :payments, :account_number, :string
  end
end
