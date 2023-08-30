class CreateVisits < ActiveRecord::Migration[7.0]
  def change
    create_table :visits do |t|
      t.references :payment, foreign_key: true
      t.string :ip
      t.text :user_agent
      t.string :cookie
      t.string :url

      t.timestamps
    end
  end
end
