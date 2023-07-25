# frozen_string_literal: true

module Supports
  class NotFoundPaymentsController < ApplicationController
    before_action :find_not_found_payment, only: %i[show]

    def index
      @pagy, @not_found_payments = pagy(NotFoundPayment.all)
      @not_found_payments = @not_found_payments.decorate
    end

    def show; end

    private

    def find_not_found_payment
      @not_found_payment = NotFoundPayment.find(params[:id])
    end
  end
end
