class AddNationalCurrencyReferenceToPaymentSystems < ActiveRecord::Migration[7.0]
  def up
    add_reference :payment_systems, :national_currency, null: true, foreign_key: true
  end
end
