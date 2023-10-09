# frozen_string_literal: true

module Admins
  module Processers
    class SettingsController < Staff::BaseController
      before_action :find_processer

      def show; end

      def update
        @processer.update(settings_params)

        redirect_back fallback_location: processer_settings_path(@processer)
      end

      private

      def find_processer
        @processer = Processer.find_by_id(params[:processer_id]).decorate
      end

      def settings_params
        params.require(:processer).permit(:nickname, :name, :processer_commission, :working_group_commission,
                                          :processer_withdrawal_commission, :working_group_withdrawal_commission,
                                          :working_group_id, :otp_payment_confirm, :sort_weight, :can_edit_summ)
      end
    end
  end
end
