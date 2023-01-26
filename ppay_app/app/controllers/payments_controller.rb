# frozen_string_literal: true

class PaymentsController < ApplicationController
  before_action :find_payment
  before_action :authenticate_signature

  def show
    @payment.show! if @payment.may_show?
  end

  private

  def find_payment
    @payment = model_class.constantize.find_by!(uuid: params[:uuid]).decorate
  end

  def authenticate_signature
    return if valid_signature?

    not_found
  end

  def valid_signature?
    params[:signature] == @payment.signature
  end
end
