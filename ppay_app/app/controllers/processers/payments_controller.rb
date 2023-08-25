# frozen_string_literal: true

module Processers
  class PaymentsController < Staff::BaseController
    before_action :find_payment, only: %i[update show]

    def index
      respond_to do |format|
        format.html do
          set_payments
        end

        format.xlsx do
          payments = current_user.payments
                                 .includes(:advertisement, :transactions)
                                 .filter_by(filtering_params)
                                 .decorate
          render xlsx: 'payments', locals: { payments: }
        end
      end
    end

    def show; end

    def update
      if params[:restore]
        @payment.update(params.permit(:arbitration, :arbitration_reason))

        @payment.restore!
      else
        @payment.update(payment_params)
      end

      render :show
    end

    private

    def mark_messages_as_read(messages)
      message_ids = messages.map(&:id)
      MessageReadStatus.where(user: current_user, message_id: message_ids).update_all(read: true)
    end

    def set_payments
      @pagy, @payments = pagy(current_user.payments.filter_by(filtering_params)
                                                   .includes(:merchant)
                                                   .order(created_at: :desc))
      @payments = @payments.decorate

      @arbitration_payments_pagy, @arbitration_payments = pagy(current_user.payments.arbitration.includes(:merchant),
                                                               page_param: :arbitration_page)
      @arbitration_payments = @arbitration_payments.decorate
    end

    def find_payment
      @payment = current_user.payments.find_by(uuid: params[:uuid]).becomes(model_class.constantize).decorate
    end

    def payment_params
      required_params.permit(:arbitration, :arbitration_reason)
    end

    def filtering_params
      params[:payment_filters]&.slice(:created_from, :created_to, :cancellation_reason, :payment_status,
                                      :payment_system, :national_currency, :national_currency_amount_from,
                                      :national_currency_amount_to, :cryptocurrency_amount_from,
                                      :cryptocurrency_amount_to, :uuid, :external_order_id)
    end
  end
end
