module Garantex
  class Member
    # поиск по nickname: Konstantin1349
    # {
    #   'nickname' => 'Konstantin1349',
    #   'verified' => true,
    #   'rating' => 504,
    #   'registered_at' => '2021-09-08',
    #   'first_deal_at' => '2021-09-08',
    #   'completed_deals' => 317,
    #   'trade_partners_count' => 203,
    #   'tg_username' => nil,
    #   'trade_volume' => '> 5M',
    #   'trade_volume_30d' => '500K - 5M',
    #   'ads_sell' => [],
    #   'ads_buy' => [{
    #     'id' => 42_504,
    #     'version_id' => 1,
    #     'member' => 'Konstantin1349',
    #     'min' => '15000.0',
    #     'max' => '18300.0',
    #     'payment_method' => 'Тиньков ',
    #     'description' => 'С карты на карту ',
    #     'direction' => 'buy',
    #     'price' => '1.001',
    #     'currency' => 'rub',
    #     'fiat_currency' => 'rub',
    #     'min_rating' => nil,
    #     'verified_only' => false
    #   }]
    # }
    attr_accessor :nickname, :verified, :rating, :full_data_hash

    def initialize(account, nickname)
      # puts "exch_member #{nickname}"
      exch_member = GarantexMember.where(nickname:).last
      # puts exch_member
      if exch_member
        # ##puts "-if exch_member"
        # если в БД есть уже запись
        # пока ничего не меняем
        # но по-хорошему нужно обновлять то, что уже более 2 недель провисело
        @nickname = nickname
        # ##puts "--@verified = exch_member.verified"
        @verified = exch_member.verified
        @rating = exch_member.rating
        # @full_data_hash = item_hash

      else
        # puts "-else exch_member"
        # если в БД нет записи
        item_hash = account.get_otc_member_profile(nickname)
        # puts item_hash
        GarantexMember.create(
          nickname:, verified: item_hash['verified'], rating: item_hash['rating'],
          registered_at: item_hash['registered_at'], first_deal_at: item_hash['first_deal_at'],
          completed_deals: item_hash['completed_deals'], trade_partners_count: item_hash['trade_partners_count'],
          tg_username: item_hash['tg_username'], trade_volume: item_hash['trade_volume'],
          trade_volume_30d: item_hash['trade_volume_30d'], ads_sell: item_hash['ads_sell'],
          ads_buy: item_hash['ads_buy']
        )
        @nickname = nickname
        @verified = item_hash['verified']
        @rating = item_hash['rating']
        # @full_data_hash = item_hash
      end
    end

    def rating_over_10?
      @rating > 10
    end
  end
end
