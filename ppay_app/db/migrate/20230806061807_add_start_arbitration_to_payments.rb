class AddStartArbitrationToPayments < ActiveRecord::Migration[7.0]
  def change
    add_column :payments, :start_arbitration, :boolean, default: false
  end
end
