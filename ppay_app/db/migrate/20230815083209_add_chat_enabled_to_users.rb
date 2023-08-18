class AddChatEnabledToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :chat_enabled, :boolean, default: true
  end
end
