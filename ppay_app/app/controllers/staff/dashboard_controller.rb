# frozen_string_literal: true

module Staff
  class DashboardController < Staff::BaseController
    def show
      @stats = processers_scope.decorate.map do |processer|
        Payments::Dashboard::GetStatsInteractor.call(processer:, filtering_params:)
      end.sort_by(&:finished).reverse

      calculate_total_stats
    end

    private

    def calculate_total_stats
      total_finished = @stats.sum(&:finished)
      total_completed = @stats.sum(&:completed)

      @total_conversion = total_finished.positive? && total_completed.positive? ?
        (total_completed.to_f / total_finished.to_f * 100).round(2) : 0

      @total_average_confirmation = total_completed.positive? ?
        @stats.sum { |stats| stats.average_confirmation * stats.completed } / total_completed : 0
    end

    def processers_scope
      Processer.where(id: current_user)
    end

    def filtering_params
      params[:payment_filters]&.slice(:national_currency, :period)
    end
  end
end
