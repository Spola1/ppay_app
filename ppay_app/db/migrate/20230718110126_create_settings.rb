class CreateSettings < ActiveRecord::Migration[7.0]
  def change
    create_table :settings do |t|
      t.boolean :receive_requests_enabled

      t.timestamps
    end
  end
end
