class AddPaymentFieldsToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :ftd_payment_exec_time_in_sec, :integer, default: 480
    add_column :users, :regular_payment_exec_time_in_sec, :integer, default: 1200
    add_column :users, :ftd_payment_default_summ, :decimal, precision: 12, scale: 2
    add_column :users, :differ_ftd_and_other_payments, :boolean, default: false
  end
end
