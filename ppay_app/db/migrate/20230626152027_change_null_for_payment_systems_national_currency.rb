class ChangeNullForPaymentSystemsNationalCurrency < ActiveRecord::Migration[7.0]
  def change
    change_column_null :payment_systems, :national_currency_id, false
  end
end
