module Garantex
  class Account
    include GarantexRequest

    def initialize(private_key, uid)
      @private_key = private_key
      @uid = uid
      @token = nil
    end

    attr_accessor :token

    def generate_new_token
      host = 'garantex.io'
      secret_key = OpenSSL::PKey.read(Base64.urlsafe_decode64(@private_key))
      payload = {
        exp: 1.hours.from_now.to_i, # JWT Request TTL in seconds since epoch
        jti: SecureRandom.hex(12).upcase
      }
      jwt_token = JWT.encode(payload, secret_key, 'RS256')
      uri = URI.parse("https://dauth.#{host}/api/v1/sessions/generate_jwt")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      request = Net::HTTP::Post.new(uri.path, 'Content-Type' => 'application/json')
      request.body = { kid: @uid, jwt_token: }.to_json
      response = http.start { |h| h.request(request) }
      data = JSON.parse response.body
      token = data['token']
      # puts token
      @token = token
    end

    def get_otc_member_profile(nickname)
      link = 'otc/profiles'
      form_data_hash = { nickname: }
      GarantexRequest.send_get(@token, link, form_data_hash)

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
      link = 'depth'
      form_data_hash = { market: }
      GarantexRequest.send_get(@token, link, form_data_hash)

      # ask_1 = asks_and_bids_hash["asks"][0]
      # bid_1 = asks_and_bids_hash["bids"][0]
      # puts "\nask 1: = #{ask_1}\n"
      # puts "\nbid 1: = #{bid_1}\n"

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

    def get_otc_bids_and_asks(currency, direction, payment_method)
      link = 'otc/ads'
      form_data_hash = { currency:, direction:, payment_method: }
      advs_hash = GarantexRequest.send_get(@token, link, form_data_hash)
      # puts "\n\n\n----- advs_hash 123: -----"
      # puts advs_hash
      # return advs_hash

      # adv_1 = advs_hash[0]
      # adv_2 = advs_hash[1]
      # puts  "\n\n-=- 1ое объявление (#{currency} #{direction} #{payment_method}): #{adv_1}\n\n"
      # puts  "\n\n-=- 2ое объявление (#{currency} #{direction} #{payment_method}): #{adv_2}\n\n"

      result_array = []
      advs_hash.each do |item|
        result_array << item
      end
      # puts "result_array size: #{result_array.size}"

      result_array

      # nickname = advs_hash[0]["member"]
      # puts "nickname: #{nickname}"
      # member_profile = self.get_otc_member_profile(nickname)
      # puts member_profile

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
      #
    end
  end
end
