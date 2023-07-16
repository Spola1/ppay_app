# frozen_string_literal: true

module RateSnapshots
  class GetAllRatesJob
    include Sidekiq::Job
    sidekiq_options queue: 'high', tags: ['get_all_rates']

    def perform
      PaymentSystem.includes(:national_currency).each do |payment_system|
        next if payment_system.payment_system_copy || payment_system.binance_name.blank?

        next unless payment_system.name == 'Sberbank'

        binance_params = {
          crypto_asset: 'USDT',
          fiat: payment_system.national_currency.name,
          payment_system_id: payment_system.id,
          payment_method: payment_system.binance_name,
          merchant_check: false,
          exchange_portal_id_for_binance: 1
        }

        GetBinanceP2pRatesJob.new.perform(
          **binance_params.merge({
                                   action: 'sell',
                                   fiat_amount: payment_system.trans_amount_deposit,
                                   position_number: payment_system.adv_position_deposit
                                 })
        )
        GetBinanceP2pRatesJob.new.perform(
          **binance_params.merge({
                                   action: 'buy',
                                   fiat_amount: payment_system.trans_amount_withdrawal,
                                   position_number: payment_system.adv_position_withdrawal
                                 })
        )
      end

      nil
    end
  end
end
