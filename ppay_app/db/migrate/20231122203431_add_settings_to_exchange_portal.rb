class AddSettingsToExchangePortal < ActiveRecord::Migration[7.0]
  def change
    add_column :exchange_portals, :settings, :jsonb, default: {}
  end
end
