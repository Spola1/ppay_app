# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pundit::Authorization
  include Pagy::Backend
  include ApplicationHelper

  around_action :set_locale

  def set_locale(&action)
    locale = I18n.locale = locale_from_url || I18n.default_locale
    I18n.with_locale locale, &action
  end

  def locale_from_url
    locale = params[:locale]
    locale if I18n.available_locales.include?(locale).to_s
  end

  def default_url_options
    { locale: I18n.locale }
  end

  MANAGEMENT_NAMESPACES = %w[admins supports].freeze

  helper_method :role_namespace, :management_namespace?

  private

  def role_namespace
    current_user.type.underscore.pluralize if current_user
  end

  def management_namespace?
    role_namespace&.in?(MANAGEMENT_NAMESPACES)
  end

  def model_class
    self.class.name.demodulize.gsub('Controller', '').singularize
  end

  def not_found
    raise ActionController::RoutingError, 'Not Found'
  end
end
