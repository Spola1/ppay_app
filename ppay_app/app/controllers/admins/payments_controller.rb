# frozen_string_literal: true

module Admins
  class PaymentsController < BaseController

    def index
      @payments = Payment.all.order(created_at: :desc).decorate
    end
  end
end
