# frozen_string_literal: true

module Processers
  module Users
    class OtpController < Staff::BaseController
      layout 'processers/users'

      def show
        issuer = request.domain
        label = "#{issuer}:#{current_user.email}"

        @provisioning_uri = current_user.otp_provisioning_uri(label, issuer:)
      end

      def update; end
    end
  end
end
