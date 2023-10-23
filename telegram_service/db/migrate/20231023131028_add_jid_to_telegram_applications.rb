class AddJidToTelegramApplications < ActiveRecord::Migration[7.0]
  def change
    add_column :telegram_applications, :jid, :string
  end
end
