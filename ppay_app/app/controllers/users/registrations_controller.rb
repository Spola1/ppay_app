# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_permitted_parameters

  def create
    params[:user] = params[:user]&.merge(type: :Merchant)
    super
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[type])
  end

  def after_sign_up_path_for(_user)
    edit_user_registration_path
  end
end
