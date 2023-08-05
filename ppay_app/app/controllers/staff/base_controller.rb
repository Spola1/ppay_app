# frozen_string_literal: true

module Staff
  class BaseController < ApplicationController
    before_action :authenticate_user!

    def arbitration_by_check
      @pagy, @payments = pagy(current_user.payments.arbitration_by_check.decorate)
    end
  end
end
