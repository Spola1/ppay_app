# frozen_string_literal: true

require 'net/http'

module Bybit
  class OtcOnline
    attr_reader :params, :usertoken

    def initialize(usertoken)
      @usertoken = usertoken
    end

    def items(params)
      @params = params
      parse_response(send_request).dig('result', 'items')
    end

    def payment_systems
      @payment_systems ||=
        parse_response(send_payments_request)
        .dig('result', 'paymentConfigVo')
        .to_h { [_1['paymentName'], _1['paymentType']] }
    end

    private

    def side = params[:trade_type].downcase == 'sell' ? '0' : '1'
    def payment = [params[:pay_type]]

    def request_body
      # params = {asset: "USDT", fiat: "RUB", merchant_check: true, page: 1,
      #           pay_type: 'Tinkoff' , trade_type: 'sell', trans_amount: 5000}
      {
        userId: '',
        tokenId: params[:asset],
        currencyId: params[:fiat],
        payment:,
        side:,
        size: '20', page: '1',
        amount: params[:trans_amount].presence.to_s,
        authMaker: false, canTrade: false
      }
    end

    def initheader
      {
        accept: 'application/json', 'accept-language': 'ru-RU', 'cache-control': 'no-cache',
        'content-type': 'application/json;charset=UTF-8', lang: 'ru-RU', platform: 'PC', pragma: 'no-cache',
        'sec-ch-ua': '"Chromium";v="116", "Not)A;Brand";v="24", "YaBrowser";v="23"',
        'sec-ch-ua-mobile': '?0', 'sec-ch-ua-platform': '"Linux"', 'sec-fetch-dest': 'empty', 'sec-fetch-mode': 'cors',
        'sec-fetch-site': 'same-site', Referer: 'https://www.bybit.com/',
        'Referrer-Policy': 'strict-origin-when-cross-origin',
        'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) ' \
                      'Chrome/116.0.5845.837 YaBrowser/23.9.1.837 (beta) Yowser/2.5 Safari/537.36',
        usertoken:
      }
    end

    def send_request
      uri = URI('https://api2.bybit.com/fiat/otc/item/online')

      Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        req = Net::HTTP::Post.new(uri, initheader)
        req.body = request_body.to_json
        puts req.body

        http.request(req)
      end
    end

    def send_payments_request
      uri = URI('https://api2.bybit.com/fiat/otc/configuration/queryAllPaymentList')

      Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        req = Net::HTTP::Post.new(uri, initheader)
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
