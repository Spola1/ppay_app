module Api
  module V1
    module Payments
      class BaseController < ActionController::API
        include ApiKeyAuthenticatable
        include Resourceable

        prepend_before_action :authenticate_with_api_key!

        def create
          preset_name = params[:preset_name]

          @object = current_bearer.becomes(Merchant).public_send(model_class_plural.to_s).new(permitted_params)

          form_customization = if preset_name.present?
            @object.merchant.form_customizations.find_by(name: preset_name)
          else
            @object.merchant.form_customizations.find_by(default: true)
          end

          if form_customization
            @object.form_customization = form_customization
          elsif preset_name.present?
            default_form_customization = @object.merchant.form_customizations.find_by(default: true)
            @object.form_customization = default_form_customization if default_form_customization
          end

          if @object.save
            render json: serialized_object, status: :created
          else
            render_object_errors(@object)
          end
        end

        private

        def permitted_params
          params.permit(
            :national_currency_amount, :national_currency, :external_order_id,
            :redirect_url, :callback_url, :locale
          )
        end

        def serializer
          "Api::V1::Payments::Create::#{model_class}Serializer".classify.constantize
        end
      end
    end
  end
end