require 'openssl'
require 'base64'
require 'json'
require 'securerandom'
require 'jwt'
# добавил active_support, чтобы ошибки не было
require 'active_support'
require 'active_support/time'
require 'net/http'
require 'net/https'
require 'yaml'
require 'time'

module GarantexRequest
  def GarantexRequest.send_get(token, link, form_data_hash)
    host = 'garantex.io'
    custom_headers = {'Authorization' => "Bearer #{token}"}
    uri = URI.parse("https://#{host}/api/v2/#{link}")

    response = Net::HTTP.start uri.hostname, uri.port, use_ssl: true do |http|
      request = Net::HTTP::Get.new uri.request_uri
      custom_headers.each { |key, value| request[key] = value }
      request.set_form_data(form_data_hash)
      http.request request
    end
    case response
    when Net::HTTPSuccess, Net::HTTPRedirection
      response_hash = JSON.parse(response.body)
      # puts "response_hash: #{response_hash}"
      return response_hash
    else
      response.value
    end
    #return nil unless Net::HTTPResponse === response # Error occured
    #return nil unless Net::HTTPOK === response # HTTP error with code
    #return nil unless response.body # Response is empty
  end

end

module Garantex
  class Account
    include GarantexRequest

    def initialize(private_key, uid)
      @private_key = private_key
      @uid = uid
      @token = nil
    end

    def token
      @token
    end

    def token=(token)
      @token = token
    end

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
      request.body = { kid: @uid, jwt_token: jwt_token }.to_json
      response = http.start {|h| h.request(request)}
      data = JSON.parse response.body
      token = data['token']
      #puts token
      @token = token
    end

    def get_otc_member_profile(nickname)
      link = 'otc/profiles'
      form_data_hash = {nickname: nickname}
      request_hash = GarantexRequest.send_get(@token, link, form_data_hash)
      #puts request_hash
      return request_hash
      # {"nickname"=>"BTC_Sanya", "verified"=>true, "rating"=>1061, "registered_at"=>"2021-07-15", "first_deal_at"=>"2021-07-30", "completed_deals"=>881, "trade_partners_count"=>462, "tg_username"=>nil, "trade_volume"=>"> 5M", "trade_volume_30d"=>"> 5M", "ads_sell"=>[], "ads_buy"=>[{"id"=>21316, "version_id"=>302, "member"=>"BTC_Sanya", "min"=>"100000.0", "max"=>"390000.0", "payment_method"=>"СРОЧНО🔥Тинькофф🔥 Быстрые переводы ⚡️⚡️⚡️", "description"=>"Онлайн 🔥💵 \r\nБыстрая сделка 🔥 \r\nОбязательно комментарий : Отс И номер сделки \r\nЕсли долго не отвечаю , пишите в чат пожалуйста)", "direction"=>"buy", "price"=>"0.9995", "currency"=>"rub", "fiat_currency"=>"rub", "min_rating"=>nil, "verified_only"=>true}]}
    end

    def get_exchange_bids_and_asks(market)
      link = 'depth'
      form_data_hash = {market: market}
      asks_and_bids_hash = GarantexRequest.send_get(@token, link, form_data_hash)

      #ask_1 = asks_and_bids_hash["asks"][0]
      #bid_1 = asks_and_bids_hash["bids"][0]
      #puts "\nask 1: = #{ask_1}\n"
      #puts "\nbid 1: = #{bid_1}\n"


      return asks_and_bids_hash
      #
      # response_hash: {"timestamp"=>1659332301, "asks"=>[{"price"=>"65.15", "volume"=>"448.14", "amount"=>"29196.32", "factor"=>"0.057", "type"=>"limit"}, {"price"=>"65.2", "volume"=>"22257.45", "amount"=>"1451185.74", "factor"=>"0.058", "type"=>"limit"}, {"price"=>"65.21", "volume"=>"2134.91", "amount"=>"139207.48", "factor"=>"0.058", "type"=>"limit"}, {"price"=>"65.25", "volume"=>"43756.75", "amount"=>"2855127.94", "factor"=>"0.059", "type"=>"limit"}, {"price"=>"65.3", "volume"=>"35606.54", "amount"=>"2325107.07", "factor"=>"0.06", "type"=>"limit"}, {"price"=>"65.35", "volume"=>"33096.12", "amount"=>"2162831.44", "factor"=>"0.061", "type"=>"limit"}, {"price"=>"65.4", "volume"=>"24026.4", "amount"=>"1571326.56", "factor"=>"0.061", "type"=>"limit"}, {"price"=>"65.45", "volume"=>"3324.83", "amount"=>"217610.12", "factor"=>"0.062", "type"=>"limit"}, {"price"=>"65.5", "volume"=>"10120.96", "amount"=>"662922.88", "factor"=>"0.063", "type"=>"limit"}, {"price"=>"65.55", "volume"=>"91707.2", "amount"=>"6011406.96", "factor"=>"0.064", "type"=>"limit"}, {"price"=>"65.6", "volume"=>"225013.57", "amount"=>"14760890.19", "factor"=>"0.065", "type"=>"limit"}, {"price"=>"65.8", "volume"=>"1721.0", "amount"=>"113241.8", "factor"=>"0.068", "type"=>"limit"}, {"price"=>"65.81", "volume"=>"20190.13", "amount"=>"1328715.69", "factor"=>"0.068", "type"=>"factor"}, {"price"=>"65.83", "volume"=>"10878.8", "amount"=>"716111.27", "factor"=>"0.068", "type"=>"limit"}, {"price"=>"65.85", "volume"=>"14546.03", "amount"=>"957856.08", "factor"=>"0.069", "type"=>"limit"}, {"price"=>"65.9", "volume"=>"72759.32", "amount"=>"4794839.19", "factor"=>"0.069", "type"=>"limit"}, {"price"=>"65.95", "volume"=>"48181.04", "amount"=>"3177539.59", "factor"=>"0.07", "type"=>"limit"}, {"price"=>"66.0", "volume"=>"1987.76", "amount"=>"131192.16", "factor"=>"0.071", "type"=>"limit"}, {"price"=>"66.15", "volume"=>"75.71", "amount"=>"5008.22", "factor"=>"0.074", "type"=>"limit"}, {"price"=>"66.49", "volume"=>"80.32", "amount"=>"5340.31", "factor"=>"0.079", "type"=>"factor"}, {"price"=>"66.5", "volume"=>"1363.98", "amount"=>"90704.67", "factor"=>"0.079", "type"=>"limit"}}
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
      form_data_hash = {currency: currency, direction: direction, payment_method: payment_method}
      advs_hash = GarantexRequest.send_get(@token, link, form_data_hash)
      #puts "\n\n\n----- advs_hash 123: -----"
      #puts advs_hash
      #return advs_hash

      # adv_1 = advs_hash[0]
      # adv_2 = advs_hash[1]
      # puts  "\n\n-=- 1ое объявление (#{currency} #{direction} #{payment_method}): #{adv_1}\n\n"
      # puts  "\n\n-=- 2ое объявление (#{currency} #{direction} #{payment_method}): #{adv_2}\n\n"

      result_array = []
      advs_hash.each do |item|
        result_array << item
      end
      # puts "result_array size: #{result_array.size}"
      return result_array
      #nickname = advs_hash[0]["member"]
      #puts "nickname: #{nickname}"
      #member_profile = self.get_otc_member_profile(nickname)
      #puts member_profile

      # {"id"=>32240, "member"=>"Yalla", "min"=>"120000.0", "max"=>"1149859.9", "payment_method"=>"💸Тинькофф💸✅ Online ✅ Перевод за 1 мин🚀 💳🤝 ", "description"=>"Доброе время суток!👋🤝 Рассмотрим предложения по работе и сотрудничеству.Формат Тиньков переводы ✴️ \u2028После оплаты пришлите, пожалуйста, чек. \u2028При переводе ОБЯЗАТЕЛЬНО указать комментарий \"номер сделки\" \u2028По вопросам для связи и сотрудничества - @Yalla19 \u2028Остерегайтесь мошенников! Заранее спасибо 😉😉😉", "direction"=>"buy", "price"=>"0.9993", "currency"=>"rub", "fiat_currency"=>"rub", "min_rating"=>nil, "verified_only"=>false}
      #
      # покупатель: Yalla (2133)
      # цена: -0.07% (вы доплачиваете)
      # сумма: 120 000.00 - 1 149 859.90 RUB
      #
    end
  end

  class Member
    # поиск по nickname: Konstantin1349
    # {"nickname"=>"Konstantin1349", "verified"=>true, "rating"=>504, "registered_at"=>"2021-09-08", "first_deal_at"=>"2021-09-08", "completed_deals"=>317, "trade_partners_count"=>203, "tg_username"=>nil, "trade_volume"=>"> 5M", "trade_volume_30d"=>"500K - 5M", "ads_sell"=>[], "ads_buy"=>[{"id"=>42504, "version_id"=>1, "member"=>"Konstantin1349", "min"=>"15000.0", "max"=>"18300.0", "payment_method"=>"Тиньков ", "description"=>"С карты на карту ", "direction"=>"buy", "price"=>"1.001", "currency"=>"rub", "fiat_currency"=>"rub", "min_rating"=>nil, "verified_only"=>false}]}
    attr_accessor :nickname, :verified, :rating, :full_data_hash

    def initialize(account, nickname)
      #puts "exch_member #{nickname}"
      exch_member = GarantexMember.where(nickname: nickname).last
      #puts exch_member
      if exch_member
        ###puts "-if exch_member"
        # если в БД есть уже запись
        # пока ничего не меняем
        # но по-хорошему нужно обновлять то, что уже более 2 недель провисело
        @nickname = nickname
        ###puts "--@verified = exch_member.verified"
        @verified = exch_member.verified
        @rating = exch_member.rating
        #@full_data_hash = item_hash

      else
        #puts "-else exch_member"
        # если в БД нет записи
        item_hash = account.get_otc_member_profile(nickname)
        #puts item_hash
        GarantexMember.create(nickname: nickname, verified: item_hash["verified"], rating: item_hash["rating"],registered_at: item_hash["registered_at"],first_deal_at: item_hash["first_deal_at"],completed_deals: item_hash["completed_deals"],trade_partners_count: item_hash["trade_partners_count"],tg_username: item_hash["tg_username"],trade_volume: item_hash["trade_volume"],trade_volume_30d: item_hash["trade_volume_30d"],ads_sell: item_hash["ads_sell"],ads_buy: item_hash["ads_buy"])
        @nickname = nickname
        @verified = item_hash["verified"]
        @rating = item_hash["rating"]
        #@full_data_hash = item_hash
      end
    end

    def rating_over_10?
      @rating > 10
    end
  end

  class Adv
    attr_accessor :adv_id, :user_nick, :min_amount, :max_amount, :payment_method_text, :description, :price, :currency, :fiat_currency, :min_rating, :verified_only

    def initialize(item_hash)
      #
      # {"id"=>42332, "member"=>"fibocrypto", "min"=>"20000.0", "max"=>"1016136.0", "payment_method"=>"Тинькофф", "description"=>"Быстрая сделка, оплата на карту Тинькофф", "direction"=>"buy", "price"=>"1.0", "currency"=>"rub", "fiat_currency"=>"rub", "min_rating"=>nil, "verified_only"=>false}
      #
      @adv_id = item_hash['id']
      @user_nick =  item_hash['member']
      @min_amount = item_hash['min'].to_f
      @max_amount = item_hash['max'].to_f
      @payment_method_text = item_hash['payment_method']
      @description = item_hash['description']
      @price = item_hash['price']&.to_f
      @currency = item_hash['currency']
      @fiat_currency = item_hash['fiat_currency']
      @min_rating = item_hash['min_rating']&.to_f
      @verified_only = item_hash['verified_only']
    end

    def description_contents_stop_words?
      #puts "\n\n ------------------------"
      #puts "\n ------description_contents_stop_words - #{self.description}"
      stop_words = ['КЭШИН','CASH IN','CASH-IN','CASH','КЕШИН','CASHIN','Кешин','QR','Qr','qr','куар','✅cash','nfc','NFC','нфс','НФС','кеш ин','КЕШ ИН','Кэшин','я у банкомата','НЕ ПЕРЕВД','НЕ ПЕРЕВОД','💵Кэшин','Кэшин']
      r = /#{stop_words.join("|")}/i
      if r === self.description || r === self.payment_method_text
        #puts "содержит"
        return true
      else
        #puts "не содержит"
        return false
      end  
    end

    def suitable_amount?(my_amount)
      # проверяем - попадаем ли мы в лимиты,
      # которые выставил человек в объявлении
      if (@min_amount <= my_amount) && (my_amount <= @max_amount)
        # puts "попадаем"
        return true
      else
        # puts "не попадаем"
        return false
      end  
    end
  end

  class OtcTrade
    attr_accessor :asset, :fiat, :fiat_amount, :trade_type

    def initialize(garantex_account, fiat,trade_type,fiat_amount,payment_method)
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
      (adv.description_contents_stop_words? != true) && (adv.suitable_amount?(@fiat_amount)) && (self.suitable_otc_member?(adv))
    end

    def suitable_advs_array
      # garantex_account.get_otc_bids_and_asks('rub', 'buy', 'тинь')
      p_method = ""
      case @payment_method
      when "sberbank"
        p_method = "сбер"
      when "tinkoff"
        p_method = "тинь"
      else
        #puts "Error: неизвестный платежный метод (#{@payment_method})"
      end
      otc_advs_array = @garantex_account.get_otc_bids_and_asks(@fiat.downcase, @trade_type.downcase, p_method)
      #puts otc_advs_array[0]
      #puts otc_advs_array
      return otc_advs_array
    end


    def choose_2_advs_from_array
      advs_array = self.suitable_advs_array
      results = []
      advs_array.each do |adv_arr_item|
        #adv = Garantex::Adv.new(adv_item)
        #puts "adv_arr_item:"
        #puts adv_arr_item
        adv = Adv.new(adv_arr_item)
        # пробегаем по объявлениям и находим
        # первые два подходящих

        #puts ".can_change?(adv): #{self.can_change?(adv)}"
        #puts "results.size: #{results.size}"
        if self.can_change?(adv) && results.size < 2
          results << adv_arr_item
        else
          #puts "-Г-Г-Г-"
        end
      end
      #puts "\n\n--- выбранные 2 объявления на Garantex P2P: ---\n\n"
      #puts "results size: #{results.size}"
      #puts results
      return results
    end
  end



  class ExchangeAdv
    attr_accessor :amount, :price, :volume, :factor, :price_type

    def initialize(item_hash)
      #
      # {"price"=>"65.15", "volume"=>"448.14", "amount"=>"29196.32", "factor"=>"0.057", "type"=>"limit"}
      #
      @amount = item_hash['amount']&.to_f
      @price = item_hash['price']&.to_f
      @volume = item_hash['volume']&.to_f
      @factor = item_hash['factor']&.to_f
      @price_type = item_hash['type']
      #@currency = item_hash['currency']
      #@fiat_currency = item_hash['fiat_currency']
      #@direction = "buy"
    end

    def suitable_amount?(my_amount)
      # проверяем - попадаем ли мы в лимиты,
      # которые выставил человек в объявлении
      if my_amount <= @amount
        #puts "попадаем c объемом на exchange gar."
        return true
      else
        #puts "не попадаем c объемом на exchange gar."
        return false
      end  
    end
  end



  class ExchangeTrade
    attr_accessor :asset, :fiat, :fiat_amount, :trade_type

    def initialize(garantex_account, crypto_asset, fiat, trade_type, fiat_amount)
      # "USDT"
      @crypto_asset = crypto_asset
      # "RUB"
      @fiat = fiat
      # 200000
      @fiat_amount = fiat_amount
      # "sell"
      @trade_type = trade_type
      # и аккаунт для выполнения всех запросов
      @garantex_account = garantex_account
    end

    def can_change?(adv)
      adv.suitable_amount?(@fiat_amount)
    end

    def suitable_advs_array
      # 'usdtrub'
      #puts "suitable_advs_array"
      market_name = "#{@crypto_asset}#{@fiat}".downcase
      #puts "market_name: #{market_name}"
      all_advs_hash = @garantex_account.get_exchange_bids_and_asks(market_name)
      #puts "all_advs_hash: \n\n#{all_advs_hash}"
      # учитываем, что у нас в хэше и покупка и продажа
      direction = ''
      case @trade_type
      when "sell"
        direction = "asks"
      else
        direction = "bids"
      end
      #puts "direction: #{direction}"
      # the ask price is the lowest price 
      # a seller will accept for the instrument.
      exchange_advs_array = all_advs_hash[direction]
      return exchange_advs_array
    end


    def choose_2_advs_from_array
      advs_array = self.suitable_advs_array
      results = []
      advs_array.each do |adv_arr_item|
        adv = ExchangeAdv.new(adv_arr_item)
        # пробегаем по объявлениям и находим
        # первые два подходящих
        if self.can_change?(adv) && results.size < 2
          results << adv_arr_item
        else
          #puts "-Г-Г-Г-"
        end
      end
      #puts "\n\n--- выбранные 2 объявления на Garantex Exchange: ---\n\n"
      #puts "results size: #{results.size}"
      #puts results
      return results
    end
  end
end