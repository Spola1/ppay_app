class CreateComments < ActiveRecord::Migration[7.0]
  def change
    create_table :comments do |t|

      t.timestamps
      t.integer  :commentable_id
      t.string   :commentable_type
    end

    add_index :comments, [:commentable_id, :commentable_type]
  end
end
