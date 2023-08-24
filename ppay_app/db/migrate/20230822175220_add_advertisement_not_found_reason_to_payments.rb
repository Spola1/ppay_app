class AddAdvertisementNotFoundReasonToPayments < ActiveRecord::Migration[7.0]
  def change
    add_column :payments, :advertisement_not_found_reason, :integer
  end
end
