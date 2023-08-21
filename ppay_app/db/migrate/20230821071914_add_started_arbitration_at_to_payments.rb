class AddStartedArbitrationAtToPayments < ActiveRecord::Migration[7.0]
  def change
    add_column :payments, :started_arbitration_at, :datetime
  end
end
