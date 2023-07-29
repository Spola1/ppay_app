# frozen_string_literal: true

module RateSnapshots
  class GetBinanceP2pRatesJob
    include Sidekiq::Job
    sidekiq_options queue: 'high', tags: ['binance_p2p_rates']

    # crypto_asset = 'USDT'
    # fiat = 'RUB'
    # action = 'sell'
    # payment_method = 'RosBankNew'
    def perform(params)
      case params.symbolize_keys
      in {crypto_asset:, fiat:, payment_system_id:, payment_method:, merchant_check:,
          exchange_portal_id_for_binance:, action:, fiat_amount:, position_number:}

        advs_params = { asset: crypto_asset, fiat:, merchant_check:, pay_types: payment_method,
                        trade_type: action, trans_amount: fiat_amount || false }
        binance_session = Binance::OpenSession.new(advs_params)

        adv = binance_session.otc_advs_array[..(position_number - 1)].last
        price_bin_otc = adv[:price].to_f

        RateSnapshot.create(direction: action, cryptocurrency: crypto_asset,
                            position_number:, exchange_portal_id: exchange_portal_id_for_binance,
                            value: price_bin_otc, adv_amount: fiat_amount, payment_system_id:)
      end
    end
  end
end
