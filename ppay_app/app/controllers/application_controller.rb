# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pundit::Authorization
  include Pagy::Backend

  before_action :set_locale

  MANAGEMENT_NAMESPACES = %w[admins supports].freeze

  helper_method :role_namespace, :management_namespace?

  private

  def set_locale
    if params[:locale]
      I18n.locale = params[:locale]
      session[:locale] = params[:locale]
    else
      I18n.locale = session[:locale] || I18n.default_locale
    end
  rescue I18n::InvalidLocale
    I18n.locale = I18n.default_locale
  end

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
