class AddTelegramPhoneToIncomingRequests < ActiveRecord::Migration[7.0]
  def change
    add_column :incoming_requests, :telegram_phone, :string
  end
end
