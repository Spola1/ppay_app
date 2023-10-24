class CreateTelegramConnections < ActiveRecord::Migration[7.0]
  def change
    create_table :telegram_connections do |t|
      t.string :status
      t.references :processer, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
