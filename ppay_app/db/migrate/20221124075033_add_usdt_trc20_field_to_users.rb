class AddUsdtTrc20FieldToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :usdt_trc20_address, :string
  end
end
