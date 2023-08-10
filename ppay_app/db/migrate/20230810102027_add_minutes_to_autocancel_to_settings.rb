class AddMinutesToAutocancelToSettings < ActiveRecord::Migration[7.0]
  def change
    add_column :settings, :minutes_to_autocancel, :integer, default: 7, null: false
  end
end
