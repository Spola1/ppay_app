# frozen_string_literal: true

module Users
  class SignInController < Staff::BaseController
    def index
      redirect_back(fallback_location: root_path)
    end
  end
end
