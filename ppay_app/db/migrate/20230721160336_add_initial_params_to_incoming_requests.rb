class AddInitialParamsToIncomingRequests < ActiveRecord::Migration[7.0]
  def change
    add_column :incoming_requests, :initial_params, :jsonb
  end
end
