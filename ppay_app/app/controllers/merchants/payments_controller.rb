# frozen_string_literal: true

module Merchants
  class PaymentsController < Staff::BaseController
    def index
      set_today_payments
      set_all_payments
    end

    private

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
      @payments = @payments.decorate
    end

    def filtering_params
      params.slice(:date_from, :date_to, :cancellation_reason, :payment_status, :payment_system, :national_currency,
                   :national_currency_amount_from, :national_currency_amount_to, :cryptocurrency_amount_from,
                   :cryptocurrency_amount_to)
    end
  end
end
