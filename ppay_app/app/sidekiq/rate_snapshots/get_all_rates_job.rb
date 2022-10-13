# frozen_string_literal: true

module RateSnapshots
  class GetAllRatesJob
    include Sidekiq::Job
    sidekiq_options queue: 'critical', tags: ['get_all_rates']

    def perform
      # делаем измерения каждые 10 секунд
      # делаем это через sleep 10
      5.times{
        GetBinanceP2pRatesJob.perform_async('USDT', 'RUB', 'sell', false, false, false, 1)
        GetBinanceP2pRatesJob.perform_async('USDT', 'RUB', 'buy', false, false, false, 1)
        sleep 10
      }
    end
  end
end
