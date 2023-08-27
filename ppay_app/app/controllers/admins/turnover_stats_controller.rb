# frozen_string_literal: true

module Admins
  class TurnoverStatsController < Staff::BaseController
    def index
      set_all_merchants
    end

    def all_stats
      respond_to do |format|
        format.xlsx do
          payments = Payment.all
          render xlsx: 'all_stats', locals: { filtering_params: }, filename:
        end
      end
    end

    private

    def filename
      "#{request.domain}_all_stats_" \
      "#{filtering_params[:created_from].to_time&.strftime('%y%m%d')}-" \
      "#{(filtering_params[:created_to].to_time || Time.zone.now).strftime('%y%m%d')}"
    end

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
