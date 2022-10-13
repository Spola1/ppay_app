# frozen_string_literal: true

class PaymentsController < ApplicationController
  before_action :find_payment, only: %i[show update confirm]
  before_action :authenticate_signature, only: %i[show update]
  before_action :authenticate_processer, only: :confirm

  def index
    @payments = Payment.all.decorate
  end

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

  def confirm
    @payment.confirm!

    redirect_to payments_path
  end

  private

  def allowed_event
    params[:event].to_sym.in?(model_class.constantize.aasm.events.map(&:name)) ?
      params[:event] :
      raise(ActionController::BadRequest)
  end

  def find_payment
    @payment = Payment.find_by(uuid: params[:uuid]).becomes(model_class.constantize).decorate
  end

  def authenticate_signature
    return if valid_signature?

    not_found
  end

  def authenticate_processer
    return if current_processer == @payment.advertisement.processer

    not_found
  end

  def valid_signature?
    params[:signature] == @payment.signature
  end
end
