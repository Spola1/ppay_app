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
      payment_system = PaymentSystem.find(params['payment_system_id'])

      Binance::RateSnapshot.new(params.merge({ action: 'buy', payment_system:,
                                               fiat_amount: payment_system.trans_amount_deposit,
                                               position_number: payment_system.adv_position_deposit }))
      Binance::RateSnapshot.new(params.merge({ action: 'sell', payment_system:,
                                               fiat_amount: payment_system.trans_amount_withdrawal,
                                               position_number: payment_system.adv_position_withdrawal }))
    end
  end
end
