class AddTelegramIdToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :telegram_id, :integer
  end
end
