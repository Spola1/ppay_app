class AddOtherProcessingIdToPayments < ActiveRecord::Migration[7.0]
  def change
    add_column :payments, :other_processing_id, :string
  end
end
