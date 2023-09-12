# frozen_string_literal: true

module Garantex
  class RateSnapshot
    include RateSnapshotable

    def initialize(params)
      @params = params.with_indifferent_access
      @params in {crypto_asset:, payment_system_id:, exchange_portal_id:, action:, fiat_amount:, position_number:}
      @payment_system = params[:payment_system]

      in_progress_lock do
        break unless otc_price.positive? && exchange_rate.positive?

        value = exchange_rate * otc_price * rate_factor

        ::RateSnapshot.create!(direction: action, cryptocurrency: crypto_asset, position_number:,
                               exchange_portal_id:, value:, adv_amount: fiat_amount, payment_system_id:)
      end
    end

    private

    def otc_price
      @otc_price ||=
        garantex_advs[..(params[:position_number] - 1)].last['price'].to_f
    end

    def exchange_rate
      @exchange_rate ||=
        garantex_market[params[:action] == 'buy' ? 'asks' : 'bids']
        .find { _1['amount'].to_f > (params[:fiat_amount] || 0) }['price'].to_f
    end

    def garantex_advs
      @garantex_advs ||=
        garantex_account.get_otc_bids_and_asks(params[:fiat].downcase,
                                               params[:action] == 'buy' ? 'sell' : 'buy',
                                               params[:payment_method], params[:fiat_amount])
    end

    def garantex_market
      @garantex_market ||=
        garantex_account.get_exchange_bids_and_asks("#{params[:crypto_asset].downcase}#{params[:fiat].downcase}")
    end

    def garantex_account
      return @garantex_account if @garantex_account

      @garantex_account = Garantex::Account.new
      @garantex_account.generate_new_token
      @garantex_account
    end
  end
end
