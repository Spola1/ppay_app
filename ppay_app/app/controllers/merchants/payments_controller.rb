# frozen_string_literal: true

module Merchants
  class PaymentsController < Staff::BaseController
    before_action :find_payment, only: :show
    after_action :create_visit, only: %i[show]

    def index
      respond_to do |format|
        format.html do
          set_today_payments
          set_all_payments
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

    def show
      @payment_receipt = @payment.payment_receipts.new

      mark_messages_as_read(@payment.chats)
    end

    private

    def find_payment
      @payment = current_user.payments.find_by(uuid: params[:uuid]).becomes(model_class.constantize).decorate
    end

    def set_today_payments
      @today_deposits = current_user.deposits.today
      @today_withdrawals = current_user.withdrawals.today
      @today_payments = current_user.payments.today
      @today_balance_change = current_user.balance.today_change
    end

    def set_all_payments
      @deposits = current_user.deposits
      @withdrawals = current_user.withdrawals
      @pagy, @filtered_payments = pagy(current_user.payments.filter_by(filtering_params))
      @filtered_payments = @filtered_payments.decorate
      @payments = current_user.payments
    end

    def filtering_params
      params[:payment_filters]&.slice(:created_from, :created_to, :cancellation_reason, :payment_status,
                                      :payment_system, :national_currency, :national_currency_amount_from,
                                      :national_currency_amount_to, :cryptocurrency_amount_from,
                                      :cryptocurrency_amount_to, :uuid, :external_order_id, :cancellation_reason)
    end
  end
end
