class AddArchiveToAdvertisements < ActiveRecord::Migration[7.0]
  def change
    add_column :advertisements, :archive_number, :string, index: true
    add_column :advertisements, :archived_at, :datetime, index: true
  end
end
