class AddSaveIncomingRequestsHistoryToAdvertisements < ActiveRecord::Migration[7.0]
  def change
    add_column :advertisements, :save_incoming_requests_history, :boolean, default: false
  end
end
