# frozen_string_literal: true

module Staff
  module Management
    class NotFoundPaymentsController < ApplicationController
      before_action :find_not_found_payment, only: %i[show destroy]

      def index
        @pagy, @not_found_payments = pagy(NotFoundPayment.order(created_at: :desc))
        @not_found_payments = @not_found_payments.decorate
      end

      def show; end

      def destroy
        if @not_found_payment.destroy
          redirect_to not_found_payments_path, notice: 'Платеж успешно удален'
        else
          redirect_to not_found_payments_path, alert: 'Ошибка удаления платежа'
        end
      end

      private

      def find_not_found_payment
        @not_found_payment = NotFoundPayment.find(params[:id]).decorate
      end
    end
  end
end
