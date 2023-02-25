class AddProcessingTypeToPayments < ActiveRecord::Migration[7.0]
  def change
    add_column :payments, :processing_type, :integer, default: 0
  end
end
