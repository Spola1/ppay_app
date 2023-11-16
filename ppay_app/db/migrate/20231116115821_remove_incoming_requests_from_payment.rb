class RemoveIncomingRequestsFromPayment < ActiveRecord::Migration[7.0]
  def change
    remove_reference :payments, :incoming_request, foreign_key: true
  end
end
