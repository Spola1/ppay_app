class CreateVisits < ActiveRecord::Migration[7.0]
  def change
    create_table :visits do |t|
      t.references :payment, foreign_key: true
      t.string :ip
      t.text :user_agent
      t.text :cookie
      t.string :url
      t.string :method
      t.text :headers
      t.text :query_parameters
      t.text :request_parameters
      t.text :session
      t.text :env
      t.boolean :ssl

      t.timestamps
    end
  end
end
