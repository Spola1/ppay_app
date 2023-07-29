class AddInProgressToExchangePortals < ActiveRecord::Migration[7.0]
  def change
    add_column :exchange_portals, :in_progress, :boolean
  end
end
