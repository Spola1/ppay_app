# frozen_string_literal: true

module Processers
  class PaymentsController < BaseController
    include ::Payments::Updateable

    before_action :find_payment, only: %i[update show]

    def index
      @deposits_confirming = current_user.deposits.confirming.decorate
      @withdrawals_transferring = current_user.withdrawals.transferring.decorate
      @payments = current_user.payments.excluding(@deposits_confirming, @withdrawals_transferring).decorate
    end

    def show
    end

    private

    def find_payment
      @payment = current_user.payments.find_by(uuid: params[:uuid]).becomes(model_class.constantize).decorate
    end

    def payment_params
      {}
    end
  end
end
