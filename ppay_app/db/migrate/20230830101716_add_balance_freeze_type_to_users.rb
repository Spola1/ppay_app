class AddBalanceFreezeTypeToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :balance_freeze_type, :integer, default: 0
  end
end
