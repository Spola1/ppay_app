# frozen_string_literal: true

module Staff
  class IncomingRequestsController < ApplicationController
    before_action :set_incoming_request, only: :show

    def index
      @pagy, @incoming_requests = pagy(IncomingRequest.filter_by(filtering_params))
      @incoming_requests = @incoming_requests.order(created_at: :desc).decorate
    end

    def show; end

    private

    def set_incoming_request
      @incoming_request = IncomingRequest.find(params[:id])
    end

    def filtering_params
      params[:incoming_request_filters]&.slice(:created_from, :created_to, :status, :national_currency,
                                               :national_currency_amount_from, :national_currency_amount_to,
                                               :uuid, :id, :card_number, :advertisement_id, :processer)
    end
  end
end
