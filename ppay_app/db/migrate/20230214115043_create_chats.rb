class CreateChats < ActiveRecord::Migration[7.0]
  def change
    create_table :chats do |t|
      t.belongs_to :user, foreign_key: true
      t.belongs_to :payment, null: false, foreign_key: true
      t.string :text, null: false

      t.timestamps
    end
  end
end
