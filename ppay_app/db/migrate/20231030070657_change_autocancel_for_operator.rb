class ChangeAutocancelForOperator < ActiveRecord::Migration[7.0]
  def change
    change_column :users, :autocancel, :boolean, default: true, null: false
  end
end
