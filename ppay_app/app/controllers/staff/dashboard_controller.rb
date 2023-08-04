# frozen_string_literal: true

module Staff
  class DashboardController < Staff::BaseController
    def show
      set_default_params

      @stats = processers_scope.decorate.map do |processer|
        Payments::Dashboard::GetStatsInteractor.call(processer:, filtering_params:)
      end
    end

    private

    def processers_scope
      Processer.where(id: current_user)
    end

    def set_default_params
      params[:payment_filters] = {} unless params[:payment_filters]

      if filtering_params[:period].blank? && filtering_params[:created_from].blank? 
        params[:payment_filters][:period] = 'last_hour'
      end
    end

    def filtering_params
      params[:payment_filters]&.slice(:created_from, :created_to, :national_currency, :period)
    end
  end
end
