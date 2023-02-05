# frozen_string_literal: true

module Binance
  class OtcTrade
    attr_accessor :asset, :fiat, :fiat_amount, :trade_type

    def initialize(asset, fiat, trade_type, fiat_amount, payment_method, merchant_check)
      # "USDT"
      @asset = asset
      # "RUB"
      @fiat = fiat
      # 200000
      @fiat_amount = fiat_amount
      # "sell"
      @trade_type = trade_type
      # "sberbank"
      @payment_method = payment_method
      # true или false
      @merchant_check = merchant_check
    end

    def enough_adv_surplus_amount?(adv)
      # проверяем - достаточен ли объем денег
      # для проведения операции по сделке
      adv.fiat_surplus_amount >= fiat_amount
    end

    def in_adv_limits?(adv)
      # проверяем - попадаем ли мы в лимиты,
      # которые выставил человек в объявлении
      (adv.min_amount <= @fiat_amount) && (@fiat_amount <= adv.max_amount)
    end

    def can_change?(adv)
      # объединяем две проверки в одном методе
      enough_adv_surplus_amount?(adv) && in_adv_limits?(adv)
    end

    def suitable_advs_array
      advs_params = { asset: @asset, fiat: @fiat, merchant_check: @merchant_check, pay_types: @payment_method,
                      trade_type: @trade_type, trans_amount: @fiat_amount }
      binance_session = OpenSession.new(advs_params)
      binance_session.otc_advs_array
    end

    def choose_4_advs_from_array
      advs_array = suitable_advs_array
      results = []
      advs_array.each do |adv_arr_item|
        # adv = Garantex::Adv.new(adv_item)
        adv = Adv.new(adv_arr_item)
        # пробегаем по объявлениям и находим
        # первые два подходящих

        # puts ".can_change?(adv): #{self.can_change?(adv)}"
        # puts "results.size: #{results.size}"
        if ((fiat_amount == false) || can_change?(adv)) && results.size < 4
          results << adv_arr_item
        else
          # puts "-1-1-1-"
        end
      end
      # puts "\n\n--- выбранные 2 объявления на Binance P2P: ---\n\n"
      # puts "results size: #{results.size}"
      # puts results
      results
    end
  end
end
