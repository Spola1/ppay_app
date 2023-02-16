class AddUrlToOrder < ActiveRecord::Migration[7.0]
  def change
    add_column :orders, :url, :string
  end
end
