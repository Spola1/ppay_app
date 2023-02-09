class AddCancelledReasonColumnToPayment < ActiveRecord::Migration[7.0]
  def change
    add_column :payments, :cancelled_reason, :integer
  end
end
