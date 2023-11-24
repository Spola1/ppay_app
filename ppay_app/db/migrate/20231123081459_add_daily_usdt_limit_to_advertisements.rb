class AddDailyUsdtLimitToAdvertisements < ActiveRecord::Migration[7.0]
  def change
    add_column :advertisements, :daily_usdt_limit, :decimal, default: 0
  end
end
