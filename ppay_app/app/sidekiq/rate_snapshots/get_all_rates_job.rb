# frozen_string_literal: true

module RateSnapshots
  class GetAllRatesJob
    include Sidekiq::Job
    sidekiq_options queue: 'high', tags: ['get_all_rates']

    BINANCE_EXCHANGE_PORTAL_ID = 1

    def perform
      skip = false

      exchange_portal.with_lock do
        if exchange_portal.in_progress
          skip = true
          next
        end
        exchange_portal.update(in_progress: true)
      end

      return if skip

      begin
        fetch_all_rates
      ensure
        exchange_portal.update(in_progress: false)
      end

      nil
    end

    def exchange_portal
      @exchange_portal ||= ExchangePortal.find(BINANCE_EXCHANGE_PORTAL_ID)
    end

    def fetch_all_rates
      return if too_recent_rate_snapshot?

      PaymentSystem.includes(:national_currency).each do |payment_system|
        next if payment_system.payment_system_copy || payment_system.binance_name.blank?

        get_rates_buy(payment_system)
        get_rates_sell(payment_system)
      end
    end

    def too_recent_rate_snapshot?
      (Time.zone.now -
       RateSnapshot.buy.by_payment_system(PaymentSystem.first)
         .order(created_at: :desc).first.created_at) < 50.seconds
    end

    def binance_params(payment_system)
      {
        crypto_asset: 'USDT',
        fiat: payment_system.national_currency.name,
        payment_system_id: payment_system.id,
        payment_method: payment_system.binance_name,
        merchant_check: false,
        exchange_portal_id_for_binance: BINANCE_EXCHANGE_PORTAL_ID
      }
    end

    def get_rates_buy(payment_system)
      GetBinanceP2pRatesJob.new.perform(
        binance_params(payment_system).merge(
          {
            action: 'buy',
            fiat_amount: payment_system.trans_amount_deposit,
            position_number: payment_system.adv_position_deposit
          }
        ).stringify_keys
      )
    end

    def get_rates_sell(payment_system)
      GetBinanceP2pRatesJob.new.perform(
        binance_params(payment_system).merge(
          {
            action: 'sell',
            fiat_amount: payment_system.trans_amount_withdrawal,
            position_number: payment_system.adv_position_withdrawal
          }
        ).stringify_keys
      )
    end
  end
end
