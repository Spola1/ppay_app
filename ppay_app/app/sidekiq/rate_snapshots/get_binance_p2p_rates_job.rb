# frozen_string_literal: true

module RateSnapshots
  class GetBinanceP2pRatesJob
    include Sidekiq::Job
    sidekiq_options queue: 'high', tags: ['binance_p2p_rates']

    attr_reader :payment_system

    # crypto_asset = 'USDT'
    # fiat = 'RUB'
    # action = 'sell'
    # payment_method = 'RosBankNew'
    def perform(params)
      @payment_system = PaymentSystem.find(params['payment_system_id'])

      get_binance_p2p_rates(
        params.merge(
          {
            action: 'buy',
            fiat_amount: payment_system.trans_amount_deposit,
            position_number: payment_system.adv_position_deposit
          }
        )
      )
      get_binance_p2p_rates(
        params.merge(
          {
            action: 'sell',
            fiat_amount: payment_system.trans_amount_withdrawal,
            position_number: payment_system.adv_position_withdrawal
          }
        )
      )
    end

    def get_binance_p2p_rates(params)
      params.symbolize_keys in {crypto_asset:, fiat:, payment_system_id:, payment_method:, merchant_check:,
                                exchange_portal_id:, action:, fiat_amount:, position_number:}

      payment_system.with_lock do
        return if payment_system.in_progress

        payment_system.update(in_progress: true)
      end

      return if too_recent_rate_snapshot?(action)

      advs_params = { asset: crypto_asset, fiat:, merchant_check:, pay_types: payment_method,
                      trade_type: action, trans_amount: fiat_amount || false }
      binance_session = Binance::OpenSession.new(advs_params)

      adv = binance_session.otc_advs_array[..(position_number - 1)].last
      price_bin_otc = adv[:price]&.to_f if adv

      if price_bin_otc
        RateSnapshot.create!(direction: action, cryptocurrency: crypto_asset,
                             position_number:, exchange_portal_id:,
                             value: price_bin_otc, adv_amount: fiat_amount, payment_system_id:)

      end
    ensure
      payment_system.update(in_progress: false)
    end

    def recent_snapshot(action)
      RateSnapshot.where(direction: action)
                  .by_payment_system(payment_system)
                  .order(created_at: :desc)
                  .first
    end

    def too_recent_rate_snapshot?(action)
      recent_snapshot(action) ? (Time.zone.now - recent_snapshot(action).created_at) < 55.seconds : false
    end
  end
end
