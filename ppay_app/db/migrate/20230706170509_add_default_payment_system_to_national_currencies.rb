class AddDefaultPaymentSystemToNationalCurrencies < ActiveRecord::Migration[7.0]
  def change
    add_reference :national_currencies, :default_payment_system, null: true, foreign_key: { to_table: :payment_systems }
  end
end
