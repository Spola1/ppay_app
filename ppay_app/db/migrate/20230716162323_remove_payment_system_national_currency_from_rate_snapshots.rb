class RemovePaymentSystemNationalCurrencyFromRateSnapshots < ActiveRecord::Migration[7.0]
  def change
    remove_column :rate_snapshots, :payment_system
    remove_column :rate_snapshots, :national_currency
  end
end
