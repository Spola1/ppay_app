class CreateWorkingGroups < ActiveRecord::Migration[7.0]
  def change
    create_table :working_groups do |t|

      t.timestamps
      t.decimal  :sell_commission
      t.decimal  :buy_commission
      t.string   :name
    end
  end
end
