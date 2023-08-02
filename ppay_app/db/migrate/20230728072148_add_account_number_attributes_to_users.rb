class AddAccountNumberAttributesToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :account_number_required, :boolean, default: false
    add_column :users, :account_number_title, :string
    add_column :users, :account_number_placeholder, :string
  end
end
