# frozen_string_literal: true

module Merchants
  class PaymentsController < BaseController

    def index
      @payments = current_user.payments.decorate
    end
  end
end
