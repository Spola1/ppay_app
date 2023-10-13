# frozen_string_literal: true

module Api
  module V1
    module ExternalProcessing
      module Payments
        module BnnProcessable
          extend ActiveSupport::Concern

          private

          def bnn_pay_service = @bnn_pay_service ||= BnnProcessingService.new

          # Update Callback part

          def handle_successful_payment_callback
            response = bnn_pay_service.orders(@payment.other_processing_id)

            @payment.update(rate_snapshot: create_rate_snapshot(response))
            @payment.bind!

            update_amount(response)
            @payment.recalculate!

            update_payment_logs
            @payment.confirm!
          end

          def create_rate_snapshot(response)
            RateSnapshot.create(
              direction: 'buy',
              cryptocurrency: 'USDT',
              exchange_portal: ExchangePortal.first,
              payment_system: PaymentSystem.find_by_name(@payment.payment_system),
              value: response['Result']['Items'][0]['AznUsdtPrice']
            )
          end

          def update_amount(response)
            amount = response['Result']['Items'][0]['ResultAmount']

            @payment.update(national_currency_amount: amount) if amount.present?
          end

          def update_payment_logs
            @payment.payment_logs.last.update(
              orders_response: bnn_pay_service.logs.select { |log| log[:type] == 'orders_response' }&.to_json
            )
          end

          def handle_failed_payment_callback
            @payment.cancel!
          end

          # Create Order part

          def latest_azn_rate_snapshot
            RateSnapshot
              .joins(payment_system: :national_currency)
              .buy.where(payment_system: { national_currencies: { name: 'AZN' } })
              .order(created_at: :desc)
              .first
          end

          def not_enough_bnn_processer_balance
            latest_azn_rate_snapshot.to_crypto(params['national_currency_amount'].to_f) >
              Processer.find_by(nickname: 'bnn').balance.amount
          end

          def process_bnn_payment
            return if params['national_currency'] != 'AZN'
            return if not_enough_bnn_processer_balance

            create_order_response = bnn_pay_service.create_order(@object.external_order_id,
                                                                 @object.national_currency_amount)
            order_hash = create_order_response['Result']['hash']
            payinfo = bnn_pay_service.payinfo(order_hash)

            update_object_attributes(order_hash, payinfo)
            create_payment_logs(order_hash)
          end

          def bnn_advertisement(payinfo)
            Advertisement.where(
              processer: Processer.where(nickname: 'bnn'),
              national_currency: 'AZN',
              payment_system: payinfo['Result']['cardDetail']['Bank']
            ).first
          end

          def update_object_attributes(order_hash, payinfo)
            @object.update(
              payment_status: 'processer_search',
              payment_system: payinfo['Result']['cardDetail']['Bank'],
              card_number: payinfo['Result']['cardDetail']['Card'],
              other_processing_id: order_hash,
              advertisement: bnn_advertisement(payinfo)
            )
          end

          def create_payment_logs(order_hash)
            logs = bnn_pay_service.logs

            @object.payment_logs.create(
              banks_response: logs.find { |log| log[:type] == 'banks_response' }&.to_json,
              create_order_response: logs.find { |log| log[:type] == 'create_order_response' }&.to_json,
              payinfo_responses: logs.select { |log| log[:type] == 'payinfo_response' }&.to_json,
              other_processing_id: order_hash
            )
          end
        end
      end
    end
  end
end
