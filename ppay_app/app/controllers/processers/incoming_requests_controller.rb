# frozen_string_literal: true

module Processers
  class IncomingRequestsController < ApplicationController
    before_action :set_incoming_request, only: :show

    def index
      @pagy, @incoming_requests = pagy(IncomingRequest.all)
      @incoming_requests = @incoming_requests.order(created_at: :desc).decorate
    end

    def show; end

    private

    def set_incoming_request
      @incoming_request = IncomingRequest.find(params[:id])
    end
  end
end
