class AddCanEditSumToOperator < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :can_edit_summ, :boolean, default: true
  end
end
