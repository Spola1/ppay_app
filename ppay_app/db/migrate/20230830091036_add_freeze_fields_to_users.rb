class AddFreezeFieldsToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :short_freeze_days, :integer
    add_column :users, :long_freeze_days, :integer
    add_column :users, :long_freeze_percentage, :decimal, precision: 5, scale: 2, default: 0.0
  end
end
