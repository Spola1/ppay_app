# frozen_string_literal: true

class PaymentsController < ApplicationController
  before_action :find_payment
  before_action :authenticate_signature
  before_action :set_locale

  def show
    @payment.show! if @payment.may_show?
  end

  private

  def set_locale
    if params[:locale]
      I18n.locale = params[:locale]
      session[:locale] = params[:locale]
    else
      params[:locale] = locale_from_currency
      I18n.locale = params[:locale]
    end
  rescue I18n::InvalidLocale
    I18n.locale = I18n.default_locale
  end

  def locale_from_currency
    locales = {
      'RUB' => :ru,
      'UZS' => :uz,
      'TJS' => :tg,
      'IDR' => :id,
      'KZT' => :kk,
      'UAH' => :uk,
      'TRY' => :tr,
      'KGS' => :ky
    }

    locales[@payment.national_currency]
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
end
