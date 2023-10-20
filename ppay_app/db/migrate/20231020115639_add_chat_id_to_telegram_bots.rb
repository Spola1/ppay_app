class AddChatIdToTelegramBots < ActiveRecord::Migration[7.0]
  def change
    add_column :telegram_bots, :chat_id, :string
  end
end
