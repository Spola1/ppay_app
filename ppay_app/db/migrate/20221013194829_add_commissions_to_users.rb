class AddCommissionsToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :deposit_commission, :decimal, precision: 15, scale: 10
    add_column :users, :withdrawal_commission, :decimal, precision: 15, scale: 10

    rename_column :working_groups, :buy_commission,  :deposit_commission
    rename_column :working_groups, :sell_commission, :withdrawal_commission

    change_column :working_groups, :deposit_commission, :decimal, precision: 15, scale: 10
    change_column :working_groups, :withdrawal_commission, :decimal, precision: 15, scale: 10
  end
end
