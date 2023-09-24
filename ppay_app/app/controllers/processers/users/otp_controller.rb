# frozen_string_literal: true

module Processers
  module Users
    class OtpController < Staff::BaseController
      layout 'processers/users'

      def show; end

      def update
        if current_user.otp_secret.blank?
          if params[:create_otp_secret]
            current_user.otp_secret = User.generate_otp_secret
            @provisioning_uri = current_user.otp_provisioning_uri(current_user.email, issuer: request.domain)
          elsif params[:otp_secret].present?
            current_user.otp_secret = params[:otp_secret]

            if current_user.validate_and_consume_otp!(params[:otp_attempt])
              current_user.save!
              redirect_back fallback_location: users_otp_path, notice: 'Ключ OTP успешно добавлен.'
            else
              redirect_back fallback_location: users_otp_path, alert: 'Не верный код подтверждения.'
            end
          end
        elsif current_user.validate_and_consume_otp!(params[:otp_attempt])
          current_user.otp_required_for_login = params[:otp_required_for_login]
          current_user.save!

          redirect_back fallback_location: users_otp_path, notice: 'Настройки успешно изменены.'
        else
          redirect_to users_otp_path, alert: 'Не верный код подтверждения.'
        end
      end
    end
  end
end
