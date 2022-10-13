class AddRateFieldToRateSnapshot < ActiveRecord::Migration[7.0]
  def change
    add_column :rate_snapshots, :value, :decimal
  end
end
