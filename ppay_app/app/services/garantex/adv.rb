# frozen_string_literal: true

module Garantex
  class Adv
    attr_accessor :adv_id, :user_nick, :min_amount, :max_amount, :payment_method_text, :description, :price, :currency,
                  :fiat_currency, :min_rating, :verified_only

    def initialize(item_hash)
      # {
      #   'id' => 42_332,
      #   'member' => 'fibocrypto',
      #   'min' => '20000.0',
      #   'max' => '1016136.0',
      #   'payment_method' => 'Тинькофф',
      #   'description' => 'Быстрая сделка, оплата на карту Тинькофф',
      #   'direction' => 'buy',
      #   'price' => '1.0',
      #   'currency' => 'rub',
      #   'fiat_currency' => 'rub',
      #   'min_rating' => nil,
      #   'verified_only' => false
      # }

      @adv_id = item_hash['id']
      @user_nick =  item_hash['member']
      @min_amount = item_hash['min'].to_f
      @max_amount = item_hash['max'].to_f
      @payment_method_text = item_hash['payment_method']
      @description = item_hash['description']
      @price = item_hash['price']&.to_f
      @currency = item_hash['currency']
      @fiat_currency = item_hash['fiat_currency']
      @min_rating = item_hash['min_rating']&.to_f
      @verified_only = item_hash['verified_only']
    end

    def description_contents_stop_words?
      # puts "\n\n ------------------------"
      # puts "\n ------description_contents_stop_words - #{self.description}"
      stop_words = ['КЭШИН', 'CASH IN', 'CASH-IN', 'CASH', 'КЕШИН', 'CASHIN', 'Кешин', 'QR', 'Qr', 'qr', 'куар', '✅cash', 'nfc',
                    'NFC', 'нфс', 'НФС', 'кеш ин', 'КЕШ ИН', 'Кэшин', 'я у банкомата', 'НЕ ПЕРЕВД', 'НЕ ПЕРЕВОД', '💵Кэшин', 'Кэшин']
      r = /#{stop_words.join("|")}/i
      r === description || r === payment_method_text
    end

    def suitable_amount?(my_amount)
      # проверяем - попадаем ли мы в лимиты,
      # которые выставил человек в объявлении
      (@min_amount <= my_amount) && (my_amount <= @max_amount)
    end
  end
end
