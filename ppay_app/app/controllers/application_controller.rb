# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pundit::Authorization
  include Pagy::Backend

  helper_method :role_namespace

  private

  def role_namespace
    current_user.type.underscore.pluralize if current_user
  end

  def model_class
    self.class.name.demodulize.gsub('Controller', '').singularize
  end

  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end
end
