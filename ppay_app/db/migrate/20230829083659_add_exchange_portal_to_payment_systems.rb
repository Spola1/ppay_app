class AddExchangePortalToPaymentSystems < ActiveRecord::Migration[7.0]
  def change
    add_reference :payment_systems, :exchange_portal, null: false, default: 1, foreign_key: true
  end
end
