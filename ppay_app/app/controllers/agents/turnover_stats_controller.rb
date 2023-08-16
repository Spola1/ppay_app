# frozen_string_literal: true

module Agents
  class TurnoverStatsController < Staff::BaseController
    def index
      set_agent_merchants
    end

    private

    def set_agent_merchants
      @pagy, @merchants = pagy(current_user.merchants)
      @merchants = @merchants.includes(:balance).order(created_at: :desc).decorate

      @filtering_params = filtering_params
    end

    def filtering_params
      params[:stats_filters]&.slice(:created_from, :created_to)
    end
  end
end
