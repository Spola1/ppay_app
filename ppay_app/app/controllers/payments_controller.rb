# frozen_string_literal: true

class PaymentsController < ApplicationController
  include Payments::Updateable

  before_action :find_payment
  before_action :authenticate_signature

  def show
    @payment.show! if @payment.may_show?
  end

  def update
    if @payment.public_send("#{ allowed_event }!", payment_params)
      render :show
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def find_payment
    @payment = Payment.find_by(uuid: params[:uuid]).becomes(model_class.constantize).decorate
  end

  def allowed_events
    %i[search check cancel]
  end

  def authenticate_signature
    return if valid_signature?

    not_found
  end

  def valid_signature?
    params[:signature] == @payment.signature
  end
end
