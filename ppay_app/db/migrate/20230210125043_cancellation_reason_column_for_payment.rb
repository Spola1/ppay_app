class CancellationReasonColumnForPayment < ActiveRecord::Migration[7.0]
  def change
    add_column :payments, :cancellation_reason, :integer
  end
end
