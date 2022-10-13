# frozen_string_literal: true

class CreateAdvertisements < ActiveRecord::Migration[7.0]
  def change
    create_table :advertisements do |t|
      t.timestamps

      # направление = buy / sell
      t.string   :direction

      t.string   :national_currency
      t.string   :cryptocurrency
      t.string   :payment_system
      t.string   :payment_system_type
      t.decimal  :min_summ, precision: 12, scale: 2
      t.decimal  :max_summ, precision: 12, scale: 2
      t.string   :card_number
      t.boolean  :autoacceptance, default: false

      # комментарий - для удобства, для пометок оператра
      t.string   :comment
      t.string   :operator_contact

      t.string   :exchange_rate_type
      t.string   :exchange_rate_source
      t.decimal  :percent, precision: 4, scale: 2
      t.decimal  :min_fix_price, precision: 12, scale: 2

      # статус = активно / неактивно
      t.boolean  :status, default: false

      # когда мы удаляем объявление - оно скрывается для юзера
      # но по факту из базы оно не удаляетс
      t.boolean  :hidden, default: false

      # связи с некоторыми моделями
      t.integer  :account_id
    end
  end
end
