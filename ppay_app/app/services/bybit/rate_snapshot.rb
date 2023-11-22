# frozen_string_literal: true

module Bybit
  class RateSnapshot
    include RateSnapshotable

    def initialize(params)
      @params = params.with_indifferent_access
      @params in { action:, crypto_asset:, exchange_portal_id:, fiat_amount:, payment_system_id:, position_number: }

      @payment_system = params[:payment_system]

      in_progress_lock do
        break unless otc_price&.positive?

        value = otc_price * rate_factor

        ::RateSnapshot.create!(direction: action, cryptocurrency: crypto_asset,
                               position_number:, exchange_portal_id:,
                               value:, adv_amount: fiat_amount, payment_system_id:)
      end
    end

    private

    def otc_price
      @otc_price ||= bybit_advs[..(params[:position_number] - 1)].last&.[]('price')&.to_f
    end

    def bybit_advs
      return @bybit_advs if @bybit_advs

      @params in { action:, crypto_asset:, fiat:, fiat_amount:, merchant_check:, payment_method: }

      @bybit_advs = otc.items({ asset: crypto_asset, fiat:, merchant_check:, pay_type:,
                                trade_type: action, trans_amount: fiat_amount })
    end

    def exchange_portal = @payment_system.exchange_portal
    def otc = @otc ||= Bybit::OtcOnline.new(exchange_portal.settings.fetch('usertoken', ''))

    def pay_type
      @params in { payment_method: }

      result = exchange_portal.settings.dig('payment_systems', payment_method)

      unless result
        exchange_portal.update(settings: exchange_portal.settings.deep_merge({ payment_systems: otc.payment_systems }))
        result = exchange_portal.settings.dig('payment_systems', payment_method)
      end

      result || '-1'
    end
  end
end
