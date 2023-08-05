# frozen_string_literal: true

module Staff
  module Management
    class DashboardController < Staff::DashboardController
      def processers_scope
        Processer.all
      end

      def filtering_params
        params[:payment_filters]&.slice(:created_from, :created_to, :national_currency, :merchant, :period)
      end
    end
  end
end
