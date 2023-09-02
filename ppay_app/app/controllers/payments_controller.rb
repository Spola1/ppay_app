# frozen_string_literal: true

class PaymentsController < ApplicationController
  before_action :find_payment
  before_action :authenticate_signature
  before_action :set_locale
  before_action :create_visit, only: %i[show]

  def show
    @payment.show! if @payment.may_show?
  end

  private

  def create_visit
    @payment.visits.create(
      ip: request.remote_ip,
      user_agent: request.user_agent,
      cookie: request.cookies.to_h.to_s,
      url: request.original_url,
      method: request.method,
      headers: request.headers.to_h.to_s,
      query_parameters: request.query_parameters.to_json,
      request_parameters: request.request_parameters.to_json,
      session: request.session.to_json,
      env: request.env.to_s,
      ssl: request.ssl?
    )
  end

  def set_locale
    I18n.locale = @payment.locale.to_sym if @payment.locale.present?
  rescue I18n::InvalidLocale
    I18n.locale = I18n.default_locale
  end

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

  def payment_params
    required_params.permit(:locale)
  end
end
