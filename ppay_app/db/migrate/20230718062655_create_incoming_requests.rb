class CreateIncomingRequests < ActiveRecord::Migration[7.0]
  def change
    create_table :incoming_requests do |t|
      t.string :request_type
      t.string :request_id
      t.string :identifier
      t.string :phone
      t.string :app
      t.string :api_key
      t.string :from
      t.string :to
      t.string :message
      t.string :res_sn
      t.string :imsi
      t.string :imei
      t.string :com
      t.string :simno
      t.string :softwareid
      t.string :custmemo
      t.integer :sendstat
      t.string :user_agent
      t.string :content

      t.timestamps
    end
  end
end
