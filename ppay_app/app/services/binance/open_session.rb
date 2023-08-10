# frozen_string_literal: true

require 'net/http'

module Binance
  class OpenSession
    attr_reader :advs_params

    def initialize(advs_params)
      @advs_params = advs_params
      @otc_advs_array = nil
    end

    def otc_advs_data
      # advs_params = {asset: "USDT", fiat: "RUB", merchant_check: true, page: 1,
      #                pay_types: 'sberbank' , trade_type: 'sell', trans_amount: 5000}
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
      form_data_hash = create_form_date_hash

      check_merchant(form_data_hash, advs_params)

      res = send_request(form_data_hash)

      parse_response(res)
    end

    def otc_advs_array
      @otc_advs_array = all_data_hash
    end

    private

    def all_data_hash
      all_data_hash = otc_advs_data
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
      end
      advs_array
    end

    def create_form_date_hash
      {
        asset: advs_params[:asset],
        fiat: advs_params[:fiat],
        # merchantCheck: advs_params[:merchant_check],
        page: 1,
        payTypes: [advs_params[:pay_types]],
        publisherType: nil,
        rows: 20,
        tradeType: advs_params[:trade_type],
        transAmount: advs_params[:trans_amount].presence
      }
    end

    def check_merchant(form_data_hash, advs_params)
      if advs_params[:merchant_check] == false
        # если мы не хотим требовать проверку на мерчанта
        # false
      else
        form_data_hash[:merchantCheck] = advs_params[:merchant_check]
      end
    end

    def send_request(form_data_hash)
      uri = URI('https://p2p.binance.com/bapi/c2c/v2/friendly/c2c/adv/search')

      Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        req = Net::HTTP::Post.new(uri)
        req.body = form_data_hash.to_json
        req.set_content_type('application/json')
        puts req.body

        http.request(req)
      end
    end

    def parse_response(res)
      case res
      when Net::HTTPSuccess, Net::HTTPRedirection
        JSON.parse(res.body)
      else
        res.value
      end
    end
  end
end
