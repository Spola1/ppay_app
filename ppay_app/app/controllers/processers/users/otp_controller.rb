# frozen_string_literal: true

module Processers
  module Users
    class OtpController < Staff::BaseController
      layout 'processers/users'

      def update
        if current_user.otp_secret.blank? && params[:create_otp_secret]
          current_user.otp_secret = User.generate_otp_secret
          current_user.save!
          @provisioning_uri = current_user.otp_provisioning_uri(current_user.email, issuer: request.domain)
        elsif current_user.validate_and_consume_otp!(params[:otp_attempt])
          current_user.otp_required_for_login = params[:otp_required_for_login]
          current_user.otp_payment_confirm = params[:otp_payment_confirm]
          current_user.save!
          redirect_back fallback_location: users_otp_path, notice: 'Настройки успешно изменены.'
        else
          redirect_to users_otp_path, alert: 'Неверный OTP код.'
        end
      end
    end
  end
end
