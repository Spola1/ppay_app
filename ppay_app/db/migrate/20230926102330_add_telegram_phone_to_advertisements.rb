class AddTelegramPhoneToAdvertisements < ActiveRecord::Migration[7.0]
  def change
    add_column :advertisements, :telegram_phone, :string
  end
end
