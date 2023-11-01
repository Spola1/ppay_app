class UpdateMobileAppRequests < ActiveRecord::Migration[7.0]
  def change
    rename_column :mobile_app_requests, :version, :application_version
    rename_column :mobile_app_requests, :current_device_ip, :device_ip

    add_column :mobile_app_requests, :api_key, :string
    add_reference :mobile_app_requests, :user
  end
end
