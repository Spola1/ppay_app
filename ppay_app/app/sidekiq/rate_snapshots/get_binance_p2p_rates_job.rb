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
        binance_otc_trade = Binance::OtcTrade.new(crypto_asset, fiat, action, fiat_amount,
                                                  payment_method, merchant_check)

        choosed_from_bin_otc = binance_otc_trade.choose_10_advs_from_array
        adv = choosed_from_bin_otc[..(position_number - 1)].last
        price_bin_otc = adv[:price].to_f

        RateSnapshot.create(direction: action, cryptocurrency: crypto_asset,
                            position_number:, exchange_portal_id: exchange_portal_id_for_binance,
                            value: price_bin_otc, adv_amount: fiat_amount, payment_system_id:)
      end
    end
  end
end
