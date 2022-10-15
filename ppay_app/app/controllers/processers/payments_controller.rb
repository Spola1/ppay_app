# frozen_string_literal: true

module Processers
  class PaymentsController < BaseController
    include ::Payments::Updateable

    before_action :find_payment, only: :update

    def index
      @payments = Payment.all.decorate
    end

    def show
      @payment.show! if @payment.may_show?
    end

    private

    def find_payment
      @payment = Payment.find_by(uuid: params[:uuid]).becomes(model_class.constantize).decorate
    end

    def allowed_events
      %i[confirm]
    end

    def after_update_action
      :index
    end
  end
end
