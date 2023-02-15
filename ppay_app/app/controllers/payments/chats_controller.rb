# frozen_string_literal: true

module Payments
  class ChatsController < ApplicationController
    before_action :find_payment

    def create
      @chat = @payment.chats.create(**chat_params, user: current_user)

      @chat.broadcast_append_to @chat.payment, partial: '/shared/chat'
    end

    private

    def find_payment
      @payment = Payment.find_by!(uuid: params[:payment_uuid]).decorate
    end

    def chat_params
      params.require(:chat).permit(:text)
    end
  end
end
