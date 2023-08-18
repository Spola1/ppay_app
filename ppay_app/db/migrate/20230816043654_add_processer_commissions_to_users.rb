class AddProcesserCommissionsToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :processer_commission, :decimal, precision: 15, scale: 10
    add_column :users, :working_group_commission, :decimal, precision: 15, scale: 10
  end
end
