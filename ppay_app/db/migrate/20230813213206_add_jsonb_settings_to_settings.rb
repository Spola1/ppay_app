class AddJsonbSettingsToSettings < ActiveRecord::Migration[7.0]
  def change
    add_column :settings, :settings, :jsonb, default: {}
  end
end
