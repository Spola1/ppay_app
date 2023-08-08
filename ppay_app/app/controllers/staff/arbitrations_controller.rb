# frozen_string_literal: true

module Staff
  class ArbitrationsController < Staff::BaseController
    def index
      if current_user.type == 'Support'
        @pagy, @payments = pagy(Payment.includes(:merchant).arbitration_by_check.decorate)
      else
        @pagy, @payments = pagy(current_user.payments.arbitration_by_check.decorate)
      end
    end
  end
end
