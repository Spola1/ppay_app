class AddBlockReasonToAdvertisements < ActiveRecord::Migration[7.0]
  def change
    add_column :advertisements, :block_reason, :integer
  end
end
