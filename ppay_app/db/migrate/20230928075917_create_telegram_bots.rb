class CreateTelegramBots < ActiveRecord::Migration[7.0]
  def change
    create_table :telegram_bots do |t|
      t.string :name

      t.timestamps
    end
  end
end
