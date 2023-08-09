# frozen_string_literal: true

module Staff
  class ArbitrationsController < Staff::BaseController
    def index
      set_all_payments
    end

    private

    def set_all_payments
      if current_user.type == 'Support'
        @pagy, @payments = pagy(Payment.arbitration_by_check.filter_by(filtering_params).includes(:merchant))
      else
        @pagy, @payments = pagy(current_user.payments.arbitration_by_check.filter_by(filtering_params))
      end

      @payments = @payments.decorate
    end

    def filtering_params
      params[:payment_filters]&.slice(:created_from, :created_to, :cancellation_reason, :payment_status,
                                      :payment_system, :national_currency, :national_currency_amount_from,
                                      :national_currency_amount_to, :cryptocurrency_amount_from,
                                      :cryptocurrency_amount_to, :uuid, :external_order_id)
    end
  end
end
