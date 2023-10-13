# frozen_string_literal: true

module Api
  module V1
    module ExternalProcessing
      module Payments
        class BaseController < ActionController::API
          include ApiKeyAuthenticatable
          include Resourceable

          prepend_before_action :authenticate_with_api_key!
          skip_before_action :authenticate_with_api_key!, only: [:update_callback]

          def create
            return render_check_required_error if check_required?

            check_other_banks
            set_object

            return render_object_errors(@object) unless @object.save

            @object.inline_search!(search_params) if @object.national_currency == 'AZN'

            return render_serialized_object if @object.inline_search!(search_params) && @object.advertisement.present?
            return render_serialized_object if process_bnn_payment

            render_object_errors(@object)
          end

          def update_callback
            data = JSON.parse(request.body.string)
            payment = Payment.find_by(other_processing_id: data['Hash'])

            if data['Status'] == 'Success'
              handle_successful_payment_callback(payment)
            else
              handle_failed_payment_callback(payment)
            end

            render json: {}, status: :ok
          end

          private

          def handle_successful_payment_callback(payment)
            bnn_pay_service = Payments::BnnProcessingService.new
            response = bnn_pay_service.get_orders(payment.other_processing_id)
            create_rate_snapshot(response)
            update_payment(payment, response, bnn_pay_service)
          end

          def create_rate_snapshot(response)
            RateSnapshot.create(exchange_portal: ExchangePortal.first,
                                value: response['Result']['Items'][0]['AznUsdtPrice'])
          end

          def update_payment(payment, response, bnn_pay_service)
            payment.update(rate_snapshot: RateSnapshot.where(payment_system_id: nil).last)

            update_amount(payment, response)

            payment.recalculate!

            update_payment_logs(payment, bnn_pay_service.logs)

            payment.update(payment_status: :completed)
          end

          def update_amount(payment, response)
            amount = response['Result']['Items'][0]['ResultAmount']

            payment.update(national_currency_amount: amount) if amount.present?
          end

          def update_payment_logs(payment, logs)
            payment.payment_logs.last.update(
              orders_response: logs.select { |log| log[:type] == 'orders_response' }&.to_json
            )
          end

          def handle_failed_payment_callback(payment)
            payment.update(payment_status: :cancelled)
          end

          def process_bnn_payment
            return if params['national_currency'] != 'AZN'

            bnn_pay_service = Payments::BnnProcessingService.new
            create_order_response = bnn_pay_service.create_order(@object.external_order_id, @object.national_currency_amount)
            order_hash = create_order_response['Result']['hash']
            payinfo = bnn_pay_service.payinfo(order_hash)

            update_object_attributes(order_hash, payinfo)
            create_payment_logs(bnn_pay_service.logs, order_hash)
          end

          def update_object_attributes(order_hash, payinfo)
            @object.update(payment_system: payinfo['Result']['cardDetail']['Bank'],
                           card_number: payinfo['Result']['cardDetail']['Card'],
                           other_processing_id: order_hash,
                           advertisement: Advertisement.where(processer: Processer.where(nickname: 'bnn'),
                                                              national_currency: 'AZN',
                                                              payment_system: @object.payment_system).first)
            @object.bind!
          end

          def create_payment_logs(logs, order_hash)
            @object.payment_logs.create(
              banks_response: logs.find { |log| log[:type] == 'banks_response' }&.to_json,
              create_order_response: logs.find { |log| log[:type] == 'create_order_response' }&.to_json,
              payinfo_responses: logs.select { |log| log[:type] == 'get_payinfo_response' }&.to_json,
              other_processing_id: order_hash
            )
          end

          def check_other_banks
            if params[model_class.underscore.to_sym][:payment_system]&.match?(/^Другой банк/i)
              params[model_class.underscore.to_sym][:payment_system] = nil
            end
          end

          def serializer
            "Api::V1::ExternalProcessing::Payments::Create::#{model_class}Serializer".classify.constantize
          end

          def check_required?
            return if permitted_params[:advertisement_id]

            current_bearer.check_required?
          end

          def render_serialized_object
            render json: serialized_object, status: :created
          end

          def render_check_required_error
            render json: {
              errors: [
                ::JsonApi::Error.new(
                  code: 422, title: 'check_required',
                  detail: I18n.t('errors.check_required_with_external_processing')
                ).to_hash
              ]
            }, status: :unprocessable_entity
          end

          def set_object
            @object = current_bearer.becomes(Merchant).public_send(model_class_plural.to_s)
                                    .new(permitted_params.merge(processing_type: :external))
          end
        end
      end
    end
  end
end
