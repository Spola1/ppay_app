# frozen_string_literal: true

module Binance
  class OtcTrade
    attr_accessor :asset, :fiat, :fiat_amount, :trade_type, :merchant_check

    def initialize(asset, fiat, trade_type, fiat_amount, payment_method, merchant_check)
      @asset = asset
      @fiat = fiat
      @fiat_amount = fiat_amount || false
      @trade_type = trade_type
      @payment_method = payment_method
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
      (adv.min_amount <= fiat_amount) && (fiat_amount <= adv.max_amount)
    end

    def can_change?(adv)
      # объединяем две проверки в одном методе
      enough_adv_surplus_amount?(adv) && in_adv_limits?(adv)
    end

    def suitable_advs_array
      return @suitable_advs_array if @suitable_advs_array

      advs_params = { asset:, fiat:, merchant_check:, pay_types: @payment_method,
                      trade_type: @trade_type, trans_amount: @fiat_amount }
      binance_session = OpenSession.new(advs_params)
      @suitable_advs_array = binance_session.otc_advs_array
    end

    def choose_10_advs_from_array
      advs_array = suitable_advs_array
      results = []
      advs_array.each do |adv_arr_item|
        adv = Adv.new(adv_arr_item)

        next unless ((fiat_amount == false) || can_change?(adv)) && results.size < 10

        results << adv_arr_item
      end
      results
    end
  end
end
