class AddDeletedAtToParanoiac < ActiveRecord::Migration[7.0]
  def change
    add_column :advertisements, :deleted_at, :datetime
    add_index :advertisements, :deleted_at
  end
end
