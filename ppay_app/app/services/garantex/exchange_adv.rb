module Garantex
  class ExchangeAdv
    attr_accessor :amount, :price, :volume, :factor, :price_type

    def initialize(item_hash)
      #
      # {"price"=>"65.15", "volume"=>"448.14", "amount"=>"29196.32", "factor"=>"0.057", "type"=>"limit"}
      #
      @amount = item_hash['amount']&.to_f
      @price = item_hash['price']&.to_f
      @volume = item_hash['volume']&.to_f
      @factor = item_hash['factor']&.to_f
      @price_type = item_hash['type']
      # @currency = item_hash['currency']
      # @fiat_currency = item_hash['fiat_currency']
      # @direction = "buy"
    end

    def suitable_amount?(my_amount)
      # проверяем - попадаем ли мы в лимиты,
      # которые выставил человек в объявлении
      my_amount <= @amount
    end
  end
end
