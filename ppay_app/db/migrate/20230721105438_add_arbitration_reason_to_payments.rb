class AddArbitrationReasonToPayments < ActiveRecord::Migration[7.0]
  def change
    add_column :payments, :arbitration_reason, :integer
  end
end
