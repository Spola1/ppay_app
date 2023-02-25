# frozen_string_literal: true

module RateSnapshots
  class GetAllRatesJob
    include Sidekiq::Job
    sidekiq_options queue: 'high', tags: ['get_all_rates']

    def perform
      # делаем измерения каждые 10 секунд
      # делаем это через sleep 10
      # 5.times do
      Settings.national_currencies.each do |currency|
        GetBinanceP2pRatesJob.perform_async('USDT', currency, 'sell', false, 'sberbank', false, 1)
        GetBinanceP2pRatesJob.perform_async('USDT', currency, 'buy', false, 'sberbank', false, 1)
      end
      # sleep 10
      # end
    end
  end
end
