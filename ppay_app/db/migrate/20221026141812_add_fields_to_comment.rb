class AddFieldsToComment < ActiveRecord::Migration[7.0]
  def change
    add_column :comments, :author_nickname, :string
    add_column :comments, :author_type, :string
    add_column :comments, :text, :text
    add_column :comments, :user_id, :integer
    add_column :comments, :user_ip, :string
    add_column :comments, :user_agent, :string
  end
end
