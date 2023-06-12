class RemoveIndexPaymentsUuid < ActiveRecord::Migration[7.0]
  def change
    remove_index :payments, name: "index_payments_uuid"
  end
end
