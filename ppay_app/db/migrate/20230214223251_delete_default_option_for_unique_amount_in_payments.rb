class DeleteDefaultOptionForUniqueAmountInPayments < ActiveRecord::Migration[7.0]
  def up
    change_column :payments, :unique_amount, :integer, default: nil
  end

  def down
    change_column :payments, :unique_amount, :integer, default: 0
  end
end
