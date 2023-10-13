# frozen_string_literal: true

module Api
  module V1
    module ExternalProcessing
      module Payments
        class BaseController < ActionController::API
          include ApiKeyAuthenticatable
          include Resourceable
          include BnnProcessable

          prepend_before_action :authenticate_with_api_key!, except: :bnn_update_callback

          def create
            return render_check_required_error if check_required?

            check_other_banks
            set_object

            return render_object_errors(@object) unless @object.save

            return render_serialized_object if process_bnn_payment
            return render_serialized_object if @object.inline_search!(search_params) && @object.advertisement.present?

            render_object_errors(@object)
          end

          def bnn_update_callback
            @payment = Payment.find_by(other_processing_id: params['Hash'])

            if params['Status'] == 'Success'
              handle_successful_payment_callback
            else
              handle_failed_payment_callback
            end

            render json: {}, status: :ok
          end

          private

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
