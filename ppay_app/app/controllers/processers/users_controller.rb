# frozen_string_literal: true

module Processers
  class UsersController < Staff::BaseController
    def settings; end

    private

    def settings_params
      params.require(:processer).permit(:telegram)
    end
  end
end
