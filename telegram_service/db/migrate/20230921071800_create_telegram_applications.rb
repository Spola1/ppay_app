class CreateTelegramApplications < ActiveRecord::Migration[7.0]
  def change
    create_table :telegram_applications do |t|
      t.string :api_id
      t.string :api_hash
      t.string :phone_number
      t.string :code
      t.string :session_name
      t.string :main_application_id

      t.timestamps
    end
  end
end
