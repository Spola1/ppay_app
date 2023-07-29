# frozen_string_literal: true

module Supports
  class IncomingRequestsController < ApplicationController
    before_action :set_incoming_request, only: :show

    def show; end

    private

    def set_incoming_request
      @incoming_request = IncomingRequest.find(params[:id])
    end
  end
end
