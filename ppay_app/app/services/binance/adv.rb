# frozen_string_literal: true

module Binance
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
end
