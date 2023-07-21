class AddRelationsToIncomingRequests < ActiveRecord::Migration[7.0]
  def change
    add_reference :incoming_requests, :payment, foreign_key: true
    add_reference :incoming_requests, :advertisement, foreign_key: true
    add_reference :incoming_requests, :card_mask, foreign_key: { to_table: :masks }
    add_reference :incoming_requests, :sum_mask, foreign_key: { to_table: :masks }
  end
end
