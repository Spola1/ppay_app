# frozen_string_literal: true

class PaymentsController < ApplicationController
  include Payments::Updateable

  before_action :find_payment
  before_action :authenticate_signature

  def show
    @payment.show! if @payment.may_show?
  end

  private

  def find_payment
    @payment = model_class.constantize.find_by!(uuid: params[:uuid]).decorate
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

  def after_update_success
    render :show
  end

  def after_update_error
    render :show, status: :unprocessable_entity
  end
end
