class AddCheckRequiredToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :check_required, :boolean, default: true
  end
end
