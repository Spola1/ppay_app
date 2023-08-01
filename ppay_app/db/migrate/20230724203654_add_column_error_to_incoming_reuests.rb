class AddColumnErrorToIncomingReuests < ActiveRecord::Migration[7.0]
  def change
    add_column :incoming_requests, :error, :text
  end
end
