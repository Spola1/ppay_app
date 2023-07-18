class AddReceiveRequestsEnabledToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :receive_requests_enabled, :boolean, default: false
  end
end
