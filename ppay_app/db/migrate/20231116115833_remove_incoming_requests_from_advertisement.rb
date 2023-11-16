class RemoveIncomingRequestsFromAdvertisement < ActiveRecord::Migration[7.0]
  def change
    remove_reference :advertisements, :incoming_request, foreign_key: true
  end
end
