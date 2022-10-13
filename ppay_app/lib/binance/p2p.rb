# frozen_string_literal: true

require 'net/http'
require 'net/https'

module Binance
  class OpenSession
    def initialize(advs_params)
      @advs_params = advs_params
      @otc_advs_data_hash = nil
      @otc_advs_array = nil
    end

    def get_otc_advs_data
      # advs_params = {asset: "USDT", fiat: "RUB", merchant_check: true, page: 1, pay_types: 'sberbank' , trade_type: 'sell', trans_amount: 5000}
      #
      #  оригинальные параметры для JSON-тела запроса
      #  {
      #      "asset": "USDT",
      #      "fiat": "RUB",
      #      "merchantCheck": true,
      #      "page": 1,
      #      "payTypes": ["RosBank"],
      #      "publisherType": null,
      #      "rows": 20,
      #      "tradeType": "SELL",
      #      "transAmount":  "5000"
      #  }
      advs_params = @advs_params

      form_data_hash = {
        asset: advs_params[:asset],
        fiat: advs_params[:fiat],
        #merchantCheck: advs_params[:merchant_check],
        page: 1,
        #payTypes: p_method,
        publisherType: nil,
        rows: 20,
        tradeType: advs_params[:trade_type],
        #transAmount: advs_params[:trans_amount].to_s
      }
      unless advs_params[:merchant_check] == false
        form_data_hash[:merchantCheck] = advs_params[:merchant_check]
      else
        # если мы не хотим требовать проверку на мерчанта
        # false
      end
      unless advs_params[:trans_amount] == false
        form_data_hash[:transAmount] = advs_params[:trans_amount].to_s
      else
        # если мы не хотим указывать сумму, то просто передаем
        # false
      end
      # ниже учитываем, что названия наши и техн. названия
      # платежного метода на бирже Бинанс отличаются
      p_method = ''
      case advs_params[:pay_types]
      when 'sberbank'
        p_method = ['RosBankNew']
      when 'tinkoff'
        p_method = ['TinkoffNew']
      when 'sberbank'
        p_method = ['RaiffeisenBank']
      when 'tinkoff'
        p_method = ['ABank']
        # RaiffeisenBankRussia
        # QIWI
        # ABank
        # HomeCreditBank
        form_data_hash[:payTypes] = p_method
      else
        p_method = ''
        puts "любой или неизвестный платежный метод (#{advs_params[:pay_types]})"
      end


      # puts "== form_data_hash.to_json: =="
      # puts form_data_hash.to_json
      uri = URI('https://p2p.binance.com/bapi/c2c/v2/friendly/c2c/adv/search')
      res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        req = Net::HTTP::Post.new(uri)
        req.body = form_data_hash.to_json
        req.set_content_type('application/json')
        http.request(req)
      end
      case res
      when Net::HTTPSuccess, Net::HTTPRedirection
        # OK
        # puts "Net::HTTPSuccess, Net::HTTPRedirection"
        # puts res
        # puts res.body
        res_hash = JSON.parse(res.body)
        # puts "res_hash: #{res_hash}"
        @otc_advs_data_hash = res_hash
        res_hash
      else
        res.value
      end
    end

    def otc_advs_array
      all_data_hash = get_otc_advs_data
      advs_array = []
      all_data_hash['data'].each do |item|
        item_hash = {}
        item_hash[:adv_no] = item['adv']['advNo']
        item_hash[:price] = item['adv']['price']
        item_hash[:surplus_amount] = item['adv']['surplusAmount']
        item_hash[:crypto_asset] = item['adv']['asset']
        item_hash[:min_amount] = item['adv']['minSingleTransAmount']
        item_hash[:max_amount] = item['adv']['maxSingleTransAmount']
        item_hash[:fiat_unit] = item['adv']['fiatUnit']
        item_hash[:user_no] = item['advertiser']['userNo']
        item_hash[:user_nick] = item['advertiser']['nickName']
        item_hash[:user_month_order_count] = item['advertiser']['monthOrderCount']
        item_hash[:month_finish_rate] = item['advertiser']['monthFinishRate']
        item_hash[:user_type] = item['advertiser']['userType']
        item_hash[:user_identity] = item['advertiser']['userIdentity']
        advs_array << item_hash
        # puts "\n#{item_hash}"
      end
      @otc_advs_array = advs_array
      advs_array
    end
  end

  class Adv
    attr_accessor :adv_no, :price, :surplus_amount, :crypto_asset, :min_amount, :max_amount, :fiat_unit, :user_no,
                  :user_nick, :user_month_order_count, :month_finish_rate, :user_type, :user_identity

    def initialize(item_hash)
      #
      # {:adv_no=>"11367926890814218240", :price=>"65.00", :surplus_amount=>"5539.56", :crypto_asset=>"USDT", :max_amount=>"870000.00", :min_amount=>"10000.00", :fiat_unit=>"RUB", :user_no=>"sc62353f480ba3cfda68d684492c9355e", :user_nick=>"shan06", :user_month_order_count=>3811, :month_finish_rate=>0.996, :user_type=>"merchant", :user_identity=>"MASS_MERCHANT"}
      #
      @adv_no = item_hash[:adv_no]
      @price =  item_hash[:price].to_f
      @surplus_amount = item_hash[:surplus_amount].to_f
      @crypto_asset = item_hash[:crypto_asset]
      @min_amount = item_hash[:min_amount].to_f
      @max_amount = item_hash[:max_amount].to_f
      @fiat_unit = item_hash[:fiat_unit]
      @user_no = item_hash[:user_no]
      @user_nick = item_hash[:user_nick]
      @user_month_order_count = item_hash[:user_month_order_count].to_i
      @month_finish_rate = item_hash[:month_finish_rate].to_f
      @user_type = item_hash[:user_type]
      @user_identity = item_hash[:user_identity]
    end

    def fiat_surplus_amount
      @surplus_amount * @price
    end
  end

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
