# frozen_string_literal: true

module Merchants
  class PaymentsController < BaseController

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
      @pagy, @payments = pagy(current_user.payments)
      @payments = @payments.decorate
    end
  end
end
