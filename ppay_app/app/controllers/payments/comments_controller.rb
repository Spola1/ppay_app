# frozen_string_literal: true

module Payments
  class CommentsController < ApplicationController
    before_action :authenticate_user!, :find_payment

    def create
      @comment = @payment.comments.create(**comment_params, user: current_user)

      render "#{role_namespace}/payments/show"
    end

    private

    def find_payment
      @payment = Payment.find_by!(uuid: params[:payment_uuid]).decorate
    end

    def comment_params
      params.require(:comment).permit(:text)
    end
  end
end
