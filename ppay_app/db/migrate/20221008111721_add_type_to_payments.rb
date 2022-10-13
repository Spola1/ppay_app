class AddTypeToPayments < ActiveRecord::Migration[7.0]
  def change
    add_column :payments, :type, :string, null: false, default: 'Deposit'
  end
end
