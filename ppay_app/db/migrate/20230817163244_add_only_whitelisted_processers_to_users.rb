class AddOnlyWhitelistedProcessersToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :only_whitelisted_processers, :boolean, default: false, null: false
  end
end
