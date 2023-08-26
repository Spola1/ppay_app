class AddColumnEqualAmountPaymentsLimitToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :equal_amount_payments_limit, :integer
  end
end
