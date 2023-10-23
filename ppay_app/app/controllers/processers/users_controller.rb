# frozen_string_literal: true

module Processers
  class UsersController < Staff::BaseController
    def settings; end

    def check_job_status
      @job_status = TelegramMicroserviceJobStatus.fetch_and_create(current_user.id)
    end

    private

    def settings_params
      params.require(:processer).permit(:telegram)
    end
  end
end
