# frozen_string_literal: true

module RateSnapshots
  class GetBinanceP2pRatesJob
    include Sidekiq::Job
    sidekiq_options queue: 'high', tags: ['binance_p2p_rates']

    def perform(crypto_asset, fiat, action, fiat_amount, payment_method, merchant_check, exchange_portal_id_for_binance)
      puts 'perform GetBinanceP2pRatesJob - started'
      # crypto_asset = "USDT"
      # fiat = "RUB"
      # fiat_amount = '2000.2'
      # action = 'sell'
      # payment_method = "sberbank"
      #
      # договорились, что берем цену 4ого объявления сверху
      # чтобы случайно не выхватывать неадекватную цену сверху
      position_number = 10
      binance_otc_trade = Binance::OtcTrade.new(crypto_asset, fiat, action, fiat_amount, payment_method, merchant_check)
      choosed_from_bin_otc = binance_otc_trade.choose_10_advs_from_array
      # (position_number-1) так как выбираем позицию в массиве
      price_bin_otc = choosed_from_bin_otc[(position_number - 1)][:price].to_f
      RateSnapshot.create(direction: action, national_currency: fiat, cryptocurrency: crypto_asset,
                          position_number:, exchange_portal_id: exchange_portal_id_for_binance,
                          value: price_bin_otc, adv_amount: 0)
    end
  end
end

# пример, как запустить в консоли "rails c":
# GetBinanceP2pRatesJob.new.perform('USDT', 'RUB', 'sell', 10000, 'sberbank', false, 1)
#
# здесь мы намеренно не указываем систему переводов, размер переводов
# и не ищем мерчантов (цены от всех подряд сканируем)
# GetBinanceP2pRatesJob.new.perform('USDT', 'RUB', 'sell', false, false, false, 1)
#
# GetBinanceP2pRatesJob.new.perform('USDT', 'RUB', 'buy', false, false, false, 1)

# ExchangePortal ID для бинанса = 1,
# так как мы его загнали через seed.rb

# RateSnapshots::GetBinanceP2pRatesJob.new.perform('USDT', 'RUB', 'sell', 10000, 'sberbank', false, 1)
