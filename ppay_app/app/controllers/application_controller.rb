# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pundit::Authorization
  include Pagy::Backend

  MANAGEMENT_NAMESPACES = %w[admins supports].freeze

  before_action :set_user_locale

  helper_method :role_namespace, :management_namespace?

  private

  def set_user_locale
    if user_signed_in?
      I18n.locale = :ru
    end
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
