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

            if payment_conditions_met?
              render json: serialized_object, status: :created
            else
              render_object_errors(@object)
            end
          end

          def update_callback
            data = JSON.parse(request.body.string)

            payment = Payment.find_by(other_processing_id: data['Hash'])

            if data['Status'] == 'Success'
              payment.confirm!
            else
              payment.cancel!
            end

            render json: {}, status: :ok
          end

          private

          def payment_conditions_met?
            @object.save && @object.inline_search!(search_params) &&
              @object.advertisement.present? &&
              (params['national_currency'] != 'AZN' || process_bnn_payment)
          end

          def process_bnn_payment
            uid = Rails.application.credentials.bnn_pay[:uid]
            private_key = Rails.application.credentials.bnn_pay[:private_key]

            bnn_pay_service = Payments::BnnProcessingService.new(uid, private_key, @object)

            banks_response = bnn_pay_service.get_banks
            puts "Banks Response Code: #{banks_response.code}"
            puts "Banks Response Body: #{banks_response.body}"

            create_order_response = bnn_pay_service.create_order(@object.external_order_id, @object.national_currency_amount)
            puts "Create Order Response Code: #{create_order_response.code}"
            puts "Create Order Response Body: #{create_order_response.body}"

            order_hash = create_order_response['Result']['hash']

            bnn_pay_service.get_payinfo(order_hash)
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
