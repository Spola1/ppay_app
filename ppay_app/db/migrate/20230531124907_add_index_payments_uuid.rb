class AddIndexPaymentsUuid < ActiveRecord::Migration[7.0]
  def change
    add_index :payments, '(uuid::text) text_pattern_ops', name: "index_payments_uuid"
  end
end
