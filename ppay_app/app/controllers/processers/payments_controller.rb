# frozen_string_literal: true

module Processers
  class PaymentsController < BaseController
    include ::Payments::Updateable

    before_action :find_payment, only: %i[update show]

    def index
      @payments = Payment.all.decorate
    end

    private

    def find_payment
      @payment = Payment.find_by(uuid: params[:uuid]).becomes(model_class.constantize).decorate
    end

    def payment_params
      {}
    end
  end
end
