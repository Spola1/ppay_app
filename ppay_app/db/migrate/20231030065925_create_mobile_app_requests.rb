class CreateMobileAppRequests < ActiveRecord::Migration[7.0]
  def change
    create_table :mobile_app_requests do |t|
      t.string :application_id
      t.string :version
      t.string :current_device_ip
      t.string :device_model

      t.timestamps
    end
  end
end
