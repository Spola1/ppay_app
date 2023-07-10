class AddPaymentSystemToRateSnapshots < ActiveRecord::Migration[7.0]
  def change
    add_reference :rate_snapshots, :payment_system, null: true, foreign_key: true
  end
end
