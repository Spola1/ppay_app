class ChangeDefaultsForBalanceFreezeColumnsInUsers < ActiveRecord::Migration[7.0]
  def up
    change_column :users, :balance_freeze_type, :integer, default: 0
    change_column :users, :long_freeze_percentage, :decimal, precision: 5, scale: 2, default: nil
  end

  def down
  end
end
