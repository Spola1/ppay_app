require 'net/http'

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
end
