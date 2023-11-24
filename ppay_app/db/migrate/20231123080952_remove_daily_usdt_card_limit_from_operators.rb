class RemoveDailyUsdtCardLimitFromOperators < ActiveRecord::Migration[7.0]
  def change
    remove_column :users, :daily_usdt_card_limit, :decimal, default: 0
  end
end
