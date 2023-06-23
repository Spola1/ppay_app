class AddTelegramToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :telegram, :string
  end
end
