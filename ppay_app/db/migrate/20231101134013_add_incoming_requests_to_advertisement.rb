class AddIncomingRequestsToAdvertisement < ActiveRecord::Migration[7.0]
  change_table :advertisements do |t|
    t.references :incoming_request, foreign_key: true
  end
end
