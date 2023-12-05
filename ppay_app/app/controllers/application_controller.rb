# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pundit::Authorization
  include Pagy::Backend

  MANAGEMENT_NAMESPACES = %w[super_admins admins supports].freeze

  before_action :set_application_locale

  helper_method :role_namespace, :management_namespace?

  around_action :set_time_zone, if: :current_user

  private

  def set_application_locale
    I18n.locale = :ru
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

  def set_time_zone(&)
    Time.use_zone(current_user.time_zone, &)
  end
end
