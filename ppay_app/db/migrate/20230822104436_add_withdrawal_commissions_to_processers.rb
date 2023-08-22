class AddWithdrawalCommissionsToProcessers < ActiveRecord::Migration[7.0]
  def up
    add_column :users, :processer_withdrawal_commission, :decimal, precision: 15, scale: 10, default: 1
    add_column :users, :working_group_withdrawal_commission, :decimal, precision: 15, scale: 10, default: 1

    # remove_column :users, :deposit_commission
    # remove_column :users, :withdrawal_commission
  end

  def down
    remove_column :users, :processer_withdrawal_commission
    remove_column :users, :working_group_withdrawal_commission
  end
end
