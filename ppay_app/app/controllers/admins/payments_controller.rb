# frozen_string_literal: true

module Admins
  class PaymentsController < Staff::BaseController

    def index
      @pagy, @payments = pagy(Payment.all.order(created_at: :desc))
      @payments = @payments.decorate
    end
  end
end
