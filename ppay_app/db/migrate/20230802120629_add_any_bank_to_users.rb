class AddAnyBankToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :any_bank, :string
  end
end
