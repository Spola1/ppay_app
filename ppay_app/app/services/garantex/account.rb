# frozen_string_literal: true

require 'jwt'
require 'net/http'
require 'securerandom'

module Garantex
  class Account
    HOST = 'garantex.org'.freeze

    def initialize(private_key = nil, uid = nil)
      @private_key = private_key || ENV.fetch('GARANTEX_PRIVATE_KEY', nil)
      @uid = uid || ENV.fetch('GARANTEX_UID', nil)
      @token = nil
    end

    attr_accessor :token

    def generate_new_token
      secret_key = OpenSSL::PKey.read(Base64.urlsafe_decode64(@private_key))
      payload = {
        exp: 1.hours.from_now.to_i, # JWT Request TTL in seconds since epoch
        jti: SecureRandom.hex(12).upcase
      }

      jwt_token = JWT.encode(payload, secret_key, 'RS256')

      uri = URI.parse("https://dauth.#{HOST}/api/v1/sessions/generate_jwt")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      request = Net::HTTP::Post.new(uri.path, 'Content-Type' => 'application/json')
      request.body = { kid: @uid, jwt_token: }.to_json
      response = http.start { |h| h.request(request) }
      data = JSON.parse response.body
      @token = data['token']
    end

    def get_otc_member_profile(nickname)
      make_request('otc/profiles', { nickname: })

      # {
      #   'nickname' => 'BTC_Sanya',
      #   'verified' => true,
      #   'rating' => 1061,
      #   'registered_at' => '2021-07-15',
      #   'first_deal_at' => '2021-07-30',
      #   'completed_deals' => 881,
      #   'trade_partners_count' => 462,
      #   'tg_username' => nil,
      #   'trade_volume' => '> 5M',
      #   'trade_volume_30d' => '> 5M',
      #   'ads_sell' => [],
      #   'ads_buy' => [{
      #     'id' => 21_316,
      #     'version_id' => 302,
      #     'member' => 'BTC_Sanya',
      #     'min' => '100000.0',
      #     'max' => '390000.0',
      #     'payment_method' => 'СРОЧНО🔥Тинькофф🔥 Быстрые переводы ⚡️⚡️⚡️',
      #     'description' => "Онлайн 🔥💵 \r\nБыстрая сделка 🔥 \r\nОбязательно комментарий : Отс И номер сделки \r\n " \
      #                      'Если долго не отвечаю , пишите в чат пожалуйста)',
      #     'direction' => 'buy',
      #     'price' => '0.9995',
      #     'currency' => 'rub',
      #     'fiat_currency' => 'rub',
      #     'min_rating' => nil,
      #     'verified_only' => true
      #   }]
      # }
    end

    def get_exchange_bids_and_asks(market)
      make_request('depth', { market: })

      # {
      #   'timestamp' => 1659332301,
      #   'asks' => [
      #     {
      #       'price' => '65.15',
      #       'volume' => '448.14',
      #       'amount' => '29196.32',
      #       'factor' => '0.057',
      #       'type' => 'limit'
      #     },
      #     {
      #       'price' => '66.5',
      #       'volume' => '1363.98',
      #       'amount' => '90704.67',
      #       'factor' => '0.079',
      #       'type' => 'limit'
      #     }
      #   ]
      # }

      #
      # ask 1: = {"price"=>"61.75", "volume"=>"29156.89", "amount"=>"1800437.96", "factor"=>"0.078", "type"=>"limit"}
      # продажа USD (красное)
      # limit + 0.078 = Фикс Цена +7,8%
      #
      # bid 1: = {"price"=>"61.53", "volume"=>"84033.55", "amount"=>"5170539.26", "factor"=>"0.074", "type"=>"factor"}
      # покупка USD (зеленое)
      # limit + 0.074 = moex +7,4%
      #
    end

    def get_otc_bids_and_asks(currency, direction, payment_method, amount = nil)
      make_request('otc/ads', { currency:, direction:, payment_method:, amount: }.compact)

      # {
      #   'id' => 32_240,
      #   'member' => 'Yalla',
      #   'min' => '120000.0',
      #   'max' => '1149859.9',
      #   'payment_method' => '💸Тинькофф💸✅ Online ✅ Перевод за 1 мин🚀 💳🤝 ',
      #   'description' => 'Доброе время суток!👋🤝 Рассмотрим предложения по работе и сотрудничеству.' \
      #                    "Формат Тиньков переводы ✴️ \u2028После оплаты пришлите, пожалуйста, чек. " \
      #                    "\u2028При переводе ОБЯЗАТЕЛЬНО указать комментарий \"номер сделки\" \u2028По вопросам для " \
      #                    "связи и сотрудничества - @Yalla19 \u2028Остерегайтесь мошенников! Заранее спасибо 😉😉😉",
      #   'direction' => 'buy',
      #   'price' => '0.9993',
      #   'currency' => 'rub',
      #   'fiat_currency' => 'rub',
      #   'min_rating' => nil,
      #   'verified_only' => false
      # }
      #
      # покупатель: Yalla (2133)
      # цена: -0.07% (вы доплачиваете)
      # сумма: 120 000.00 - 1 149 859.90 RUB
    end

    private

    def conn
      @conn ||= Faraday.new do |builder|
        builder.adapter :async_http, timeout: 60
        builder.request :json
        builder.request :authorization, 'Bearer', -> { token }
        builder.response :json
      end
    end

    def make_request(link, form_data_hash)
      puts "garantex make_request: #{link} #{form_data_hash}"

      url = "https://#{HOST}/api/v2/#{link}"

      conn.get(url, form_data_hash).body
    end
  end
end
