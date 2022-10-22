# frozen_string_literal: true

module Merchants
  class PaymentsController < BaseController

    def index
      @payments = current_user.payments.order(created_at: :desc).decorate
    end
  end
end
