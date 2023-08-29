# frozen_string_literal: true

module RateSnapshots
  class GetAllRatesJob
    include Sidekiq::Job
    sidekiq_options queue: 'high', tags: ['get_all_rates']

    BINANCE_EXCHANGE_PORTAL_ID = 1

    def perform
      PaymentSystem.includes(:national_currency).each do |payment_system|
        next if payment_system.payment_system_copy || payment_system.exchange_name.blank?

        GetBinanceP2pRatesJob.perform_async(
          {
            crypto_asset: 'USDT',
            fiat: payment_system.national_currency.name,
            payment_system_id: payment_system.id,
            payment_method: payment_system.exchange_name,
            merchant_check: false,
            exchange_portal_id_for_binance: payment_system.exchange_portal_id
          }.stringify_keys
        )
      end
    end
  end
end
