class AddArbitrationMethodToPayments < ActiveRecord::Migration[7.0]
  def change
    add_column :payments, :arbitration_method, :integer
  end
end
