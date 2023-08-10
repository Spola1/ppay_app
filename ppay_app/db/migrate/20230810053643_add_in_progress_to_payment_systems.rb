class AddInProgressToPaymentSystems < ActiveRecord::Migration[7.0]
  def change
    add_column :payment_systems, :in_progress, :boolean
  end
end
