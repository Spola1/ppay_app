# frozen_string_literal: true

module Garantex
  class RateSnapshot
    attr_reader :payment_system, :params

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

    def in_progress_lock
      payment_system.with_lock do
        return if payment_system.in_progress

        payment_system.update(in_progress: true)
      end

      return if too_recent_rate_snapshot?

      yield
    ensure
      payment_system.update(in_progress: false)
    end

    def recent_snapshot
      @recent_snapshot ||=
        ::RateSnapshot.where(direction: params[:action])
                      .by_payment_system(payment_system)
                      .order(created_at: :desc)
                      .first
    end

    def too_recent_rate_snapshot?
      recent_snapshot ? (Time.zone.now - recent_snapshot.created_at) < 55.seconds : false
    end

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

    def rate_factor
      if params[:action] == 'buy'
        1 + (payment_system.extra_percent_deposit / 100)
      else
        1 - (payment_system.extra_percent_withdrawal / 100)
      end
    end
  end
end
