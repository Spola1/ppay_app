module Garantex
  class ExchangeTrade
    attr_accessor :asset, :fiat, :fiat_amount, :trade_type

    def initialize(garantex_account, crypto_asset, fiat, trade_type, fiat_amount)
      # "USDT"
      @crypto_asset = crypto_asset
      # "RUB"
      @fiat = fiat
      # 200000
      @fiat_amount = fiat_amount
      # "sell"
      @trade_type = trade_type
      # и аккаунт для выполнения всех запросов
      @garantex_account = garantex_account
    end

    def can_change?(adv)
      adv.suitable_amount?(@fiat_amount)
    end

    def suitable_advs_array
      # 'usdtrub'
      # puts "suitable_advs_array"
      market_name = "#{@crypto_asset}#{@fiat}".downcase
      # puts "market_name: #{market_name}"
      all_advs_hash = @garantex_account.get_exchange_bids_and_asks(market_name)
      # puts "all_advs_hash: \n\n#{all_advs_hash}"
      # учитываем, что у нас в хэше и покупка и продажа
      direction = ''
      direction = case @trade_type
                  when 'sell'
                    'asks'
                  else
                    'bids'
                  end
      # puts "direction: #{direction}"
      # the ask price is the lowest price
      # a seller will accept for the instrument.
      all_advs_hash[direction]
    end

    def choose_2_advs_from_array
      advs_array = suitable_advs_array
      results = []
      advs_array.each do |adv_arr_item|
        adv = ExchangeAdv.new(adv_arr_item)
        # пробегаем по объявлениям и находим
        # первые два подходящих
        if can_change?(adv) && results.size < 2
          results << adv_arr_item
        else
          # puts "-Г-Г-Г-"
        end
      end
      # puts "\n\n--- выбранные 2 объявления на Garantex Exchange: ---\n\n"
      # puts "results size: #{results.size}"
      # puts results
      results
    end
  end
end
