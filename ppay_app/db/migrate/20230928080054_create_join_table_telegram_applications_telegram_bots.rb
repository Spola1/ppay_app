class CreateJoinTableTelegramApplicationsTelegramBots < ActiveRecord::Migration[7.0]
  def change
    create_join_table :telegram_applications, :telegram_bots do |t|
      t.index [:telegram_application_id, :telegram_bot_id], name: 'index_ta_tb_on_ta_id_and_tb_id'
      t.index [:telegram_bot_id, :telegram_application_id], name: 'index_tb_ta_on_tb_id_and_ta_id'
    end
  end
end
