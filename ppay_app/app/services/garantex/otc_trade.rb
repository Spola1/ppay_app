# frozen_string_literal: true

module Garantex
  class OtcTrade
    attr_accessor :asset, :fiat, :fiat_amount, :trade_type

    def initialize(garantex_account, fiat, trade_type, fiat_amount, payment_method)
      # "RUB"
      @fiat = fiat
      # 200000
      @fiat_amount = fiat_amount
      # "sell"
      @trade_type = trade_type
      # "sberbank"
      @payment_method = payment_method
      # добавляем объект "аккаунт", чтобы
      # посмотреть данные по члену площадки
      @garantex_account = garantex_account
    end

    def suitable_otc_member?(adv)
      otc_member = Member.new(@garantex_account, adv.user_nick)
      otc_member.rating_over_10?
    end

    def can_change?(adv)
      (adv.description_contents_stop_words? != true) && adv.suitable_amount?(@fiat_amount) && suitable_otc_member?(adv)
    end

    def suitable_advs_array
      # garantex_account.get_otc_bids_and_asks('rub', 'buy', 'тинь')
      p_method = ''
      case @payment_method
      when 'sberbank'
        p_method = 'сбер'
      when 'tinkoff'
        p_method = 'тинь'
      else
        # puts "Error: неизвестный платежный метод (#{@payment_method})"
      end
      @garantex_account.get_otc_bids_and_asks(@fiat.downcase, @trade_type.downcase, p_method)
      # puts otc_advs_array[0]
      # puts otc_advs_array
    end

    def choose_2_advs_from_array
      advs_array = suitable_advs_array
      results = []
      advs_array.each do |adv_arr_item|
        # adv = Garantex::Adv.new(adv_item)
        # puts "adv_arr_item:"
        # puts adv_arr_item
        adv = Adv.new(adv_arr_item)
        # пробегаем по объявлениям и находим
        # первые два подходящих

        # puts ".can_change?(adv): #{self.can_change?(adv)}"
        # puts "results.size: #{results.size}"
        if can_change?(adv) && results.size < 2
          results << adv_arr_item
        else
          # puts "-Г-Г-Г-"
        end
      end
      # puts "\n\n--- выбранные 2 объявления на Garantex P2P: ---\n\n"
      # puts "results size: #{results.size}"
      # puts results
      results
    end
  end
end
