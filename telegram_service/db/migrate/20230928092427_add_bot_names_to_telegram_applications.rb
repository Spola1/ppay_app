class AddBotNamesToTelegramApplications < ActiveRecord::Migration[7.0]
  def change
    add_column :telegram_applications, :bot_names, :string, array: true, default: []
  end
end
