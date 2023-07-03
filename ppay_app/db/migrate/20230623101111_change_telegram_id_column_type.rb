class ChangeTelegramIdColumnType < ActiveRecord::Migration[7.0]
  def change
    change_column :users, :telegram_id, :string
  end
end
