# frozen_string_literal: true

module Staff
  class DashboardController < Staff::BaseController
    def show
      @stats = processers_scope.decorate.map do |processer|
        Payments::Dashboard::GetStatsInteractor.call(processer:, filtering_params:)
      end.sort_by(&:finished).reverse
    end

    private

    def processers_scope
      Processer.where(id: current_user)
    end

    def filtering_params
      params[:payment_filters]&.slice(:national_currency, :period)
    end
  end
end
