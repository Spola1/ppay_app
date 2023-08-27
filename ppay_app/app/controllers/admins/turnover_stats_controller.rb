# frozen_string_literal: true

module Admins
  class TurnoverStatsController < Staff::BaseController
    def index
      set_all_merchants
    end

    private

    def set_all_merchants
      @pagy, @merchants = pagy(Merchant.all)
      @merchants = @merchants.includes(:balance).order(created_at: :desc).decorate

      @filtering_params = filtering_params
    end

    def filtering_params
      params[:stats_filters]&.slice(:created_from, :created_to)
    end
  end
end
