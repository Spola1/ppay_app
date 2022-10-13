class CreateCards < ActiveRecord::Migration[7.0]
  def change
    create_table :cards do |t|

      t.timestamps

      t.string :number
      t.string :expiration
      t.string :first_name
      t.string :last_name
      t.string :cvv
    end
  end
end
