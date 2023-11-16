class AddIncomingRequestsToPayment < ActiveRecord::Migration[7.0]
  def change
    change_table :payments do |t|
      t.references :incoming_request, foreign_key: true
    end
  end
end
