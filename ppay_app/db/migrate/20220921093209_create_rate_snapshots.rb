# frozen_string_literal: true

class CreateRateSnapshots < ActiveRecord::Migration[7.0]
  def change
    create_table :rate_snapshots do |t|
      t.timestamps
      # направление обмена
      # sell / buy
      t.string  :direction
      # с какой криптой работаем
      # USDT / USDC / ...
      t.string  :cryptocurrency
      # система переводов
      # "Sberbank", "Tinkoff", "Raiffeisen", "AlfaBank"
      t.string  :payment_system
      # позиция объявления в стакане
      # мы будем пока брать номер 4 всегда
      t.integer :position_number

      # связь с обменным порталом
      t.integer :exchange_portal_id
    end
  end
end
