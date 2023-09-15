class CreateTelegramSettings < ActiveRecord::Migration[7.0]
  def change
    create_table :telegram_settings do |t|
      t.references :user, null: false, foreign_key: true
      t.boolean :balance_request_deposit, default: true
      t.boolean :balance_request_withdraw, default: true

      t.timestamps
    end

    reversible do |direction|
      direction.up do
        Admin.find_each { |user| user.create_telegram_setting }
      end
    end
  end
end
