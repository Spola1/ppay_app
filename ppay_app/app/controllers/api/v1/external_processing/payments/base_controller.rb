# frozen_string_literal: true

module Api
  module V1
    module ExternalProcessing
      module Payments
        class BaseController < ActionController::API
          include ApiKeyAuthenticatable
          include Resourceable

          prepend_before_action :authenticate_with_api_key!

          def create
            return render_check_required_error if check_required?

            check_other_banks
            set_object

            if @object.save && @object.inline_search!(search_params) && @object.advertisement.present?
              render json: serialized_object, status: :created
            else
              render_object_errors(@object)
            end
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
