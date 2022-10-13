# frozen_string_literal: true

class CreatePayments < ActiveRecord::Migration[7.0]
  def change
    create_table :payments do |t|
      t.timestamps

      # тип сделки
      # продажа / покупка
      # направление = buy / sell
      t.string   :direction

      # крипто-валюта
      # USDT_TRC20
      t.string   :cryptocurrency

      # кол-во в криптовалюте
      # 307.4949394
      t.decimal  :cryptocurrency_amount, precision: 12, scale: 2

      # нац. валюта
      # RUB
      t.string   :national_currency

      # кол-во в нац валюте
      # 20951.00
      t.decimal  :national_currency_amount, precision: 12, scale: 2

      # платежная система
      # Sberbank
      t.string   :payment_system

      # статус
      # Завершена
      t.string   :payment_status

      # на каком статусе был отменен, если отменили
      t.string   :cancelled_on_status

      # для связи с рекламным объявлений
      t.integer  :advertisement_id

      # для связи с мерчантом
      t.integer  :merchant_id

      # для связи со снэпшотом курсов валют
      t.integer  :rate_snapshot_id

      # IP-адрес с которого был инициирован запрос
      t.string  :first_ip

      # user-agent с которого был инициирован запрос
      t.string  :first_user_agent
    end
  end
end
