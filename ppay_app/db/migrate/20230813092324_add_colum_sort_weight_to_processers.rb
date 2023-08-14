class AddColumSortWeightToProcessers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :sort_weight, :float, default: 1, null: false
  end
end
