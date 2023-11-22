# frozen_string_literal: true

module RateSnapshots
  class GetAllRatesJob
    include Sidekiq::Job
    sidekiq_options queue: 'low', tags: ['get_all_rates']

    def perform
      PaymentSystem.includes(:national_currency, :exchange_portal).each do |payment_system|
        next if payment_system.payment_system_copy || payment_system.exchange_name.blank?

        get_rates_job(payment_system.exchange_portal.name)&.perform_async(
          {
            crypto_asset: 'USDT',
            fiat: payment_system.national_currency.name,
            payment_system_id: payment_system.id,
            payment_method: payment_system.exchange_name,
            merchant_check: false,
            exchange_portal_id: payment_system.exchange_portal_id
          }.stringify_keys
        )
      end
    end

    def get_rates_job(portal_name)
      "::RateSnapshots::Get#{portal_name.parameterize.underscore.camelize}RatesJob".camelize.constantize
    end
  end
end
