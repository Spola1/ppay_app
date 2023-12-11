# frozen_string_literal: true

module Bybit
  class OtcOnline
    attr_reader :params

    def initialize(cookies)
      parse_cookies(cookies)
    end

    def items(params)
      @params = params
      items_request.dig('result', 'items')
    end

    def payment_systems
      @payment_systems ||=
        payment_systems_request.dig('result', 'paymentConfigVo')
                               .to_h { [_1['paymentName'].strip, _1['paymentType']] }
    end

    def cookies = cookie_jar.to_json

    private

    def cookie_jar = @cookie_jar ||= HTTP::CookieJar.new

    def parse_cookies(cookies)
      JSON.parse(cookies).each do |cookie|
        cookie_jar.add(HTTP::Cookie.new(
                         cookie['name'], cookie['value'],
                         domain: cookie['domain'],
                         expires: cookie['expiry'] ? Time.at(cookie['expiry']) : nil,
                         httponly: cookie['httpOnly'],
                         path: cookie['path'],
                         secure: cookie['secure']
                       ))
      end
    end

    def side = params[:trade_type].to_s.downcase == 'sell' ? '0' : '1'
    def payment = [params[:pay_type]]

    def request_body
      # params = {asset: "USDT", fiat: "RUB", merchant_check: true, page: 1,
      #           pay_type: 'Tinkoff' , trade_type: 'sell', trans_amount: 5000}
      {
        userId: '',
        tokenId: params[:asset] || 'USDT',
        currencyId: params[:fiat] || 'RUB',
        payment:,
        side:,
        size: '20', page: '1',
        amount: params[:trans_amount].presence.to_s,
        authMaker: false, canTrade: false
      }
    end

    def usertoken = cookie_jar.cookies.find { _1.name == 'b_t_c_k' }.value

    def headers
      { accept: 'application/json', 'accept-language': 'ru-RU', 'cache-control': 'no-cache',
        'content-type': 'application/json;charset=UTF-8', lang: 'ru-RU', platform: 'PC', pragma: 'no-cache',
        'sec-ch-ua': '"Chromium";v="116", "Not)A;Brand";v="24", "YaBrowser";v="23"',
        'sec-ch-ua-mobile': '?0', 'sec-ch-ua-platform': '"Linux"', 'sec-fetch-dest': 'empty', 'sec-fetch-mode': 'cors',
        'sec-fetch-site': 'same-site', referer: 'https://www.bybit.com/',
        'Referrer-Policy': 'strict-origin-when-cross-origin',
        'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) ' \
                      'Chrome/116.0.5845.837 YaBrowser/23.9.1.837 (beta) Yowser/2.5 Safari/537.36',
        cookie: HTTP::Cookie.cookie_value(cookie_jar.cookies), usertoken: }
    end

    def conn
      @conn ||= Faraday.new(url: 'https://api2.bybit.com', headers:) do |builder|
        builder.use :cookie_jar, jar: cookie_jar
        builder.request :json
        builder.response :json
      end
    end

    def items_request
      conn.post('/fiat/otc/item/online', request_body).body
    end

    def payment_systems_request
      conn.post('/fiat/otc/configuration/queryAllPaymentList').body
    end
  end
end
