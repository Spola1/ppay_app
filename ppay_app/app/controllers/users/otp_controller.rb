# frozen_string_literal: true

module Users
  class OtpController < ApplicationController
    before_action :authenticate_user!, except: %i[show verify]

    def show; end

    def verify
      verifier = Rails.application.message_verifier(:otp_session)
      user_id = verifier.verify(session[:otp_token])
      user = User.find(user_id)

      if user.validate_and_consume_otp!(params[:otp_attempt])
        sign_in(:user, user)
        redirect_to root_path, notice: 'Logged in successfully!'
      else
        flash[:alert] = 'Invalid OTP code.'

        redirect_to new_user_session_path
      end
    end
  end
end
