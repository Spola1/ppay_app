class AddSimbankSenderToAdvertisements < ActiveRecord::Migration[7.0]
  def change
    add_column :advertisements, :simbank_sender, :string
    add_reference :incoming_requests, :user
  end
end
