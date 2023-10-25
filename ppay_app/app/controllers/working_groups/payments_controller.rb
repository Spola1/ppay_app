# frozen_string_literal: true

module WorkingGroups
  class PaymentsController < Staff::BaseController
    before_action :find_payment, only: %i[show]

    def index
      respond_to do |format|
        format.html do
          set_payments
        end

        format.xlsx do
          payments = current_user.payments.joins(advertisement: { processer: :working_group })
                                 .includes(:advertisement, :transactions)
                                 .filter_by(filtering_params)
                                 .decorate

          render xlsx: 'payments', locals: { payments: }
        end
      end
    end

    def show; end

    private

    def set_payments
      scope = current_user.payments.joins(advertisement: { processer: :working_group })

      @arbitration_payments_pagy, @arbitration_payments = pagy(scope.arbitration, page_param: :arbitration_page)
      @arbitration_payments = @arbitration_payments.decorate

      @pagy, @payments = pagy(scope.filter_by(filtering_params))
      @payments = @payments.decorate
    end

    def find_payment
      @payment = current_user.payments.joins(advertisement: { processer: :working_group })
                             .find_by(uuid: params[:uuid])
                             .becomes(model_class.constantize)
                             .decorate
    end

    def filtering_params
      params[:payment_filters]&.slice(:created_from, :created_to, :cancellation_reason, :payment_status,
                                      :payment_system, :national_currency, :national_currency_amount_from,
                                      :national_currency_amount_to, :cryptocurrency_amount_from,
                                      :cryptocurrency_amount_to, :uuid, :external_order_id)
    end
  end
end
