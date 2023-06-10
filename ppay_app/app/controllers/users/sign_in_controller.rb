class Users::SignInController < ApplicationController
  before_action :authenticate_user!

  def index
    redirect_back(fallback_location: root_path)
  end
end
