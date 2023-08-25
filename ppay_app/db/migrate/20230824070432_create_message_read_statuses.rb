class CreateMessageReadStatuses < ActiveRecord::Migration[7.0]
  def change
    create_table :message_read_statuses do |t|
      t.references :user, foreign_key: true
      t.references :message, polymorphic: true, null: false
      t.boolean :read, default: false

      t.timestamps
    end
  end
end
