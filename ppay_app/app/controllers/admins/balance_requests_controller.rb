# frozen_string_literal: true

module Admins
  class BalanceRequestsController < Staff::BaseController
    include Staff::BalanceRequests::EventFireable

    STATUS_EVENTS_MAPPING = {
      'completed' => :complete,
      'cancelled' => :cancel
    }.freeze

    before_action :find_balance_request, except: %i[new index]

    def index
      @pagy, @balance_requests = pagy(BalanceRequest.all.order(created_at: :desc))
    end

    def show; end

    def new
      @balance_request = BalanceRequest.new
    end

    def edit; end

    def update
      @balance_request.update(balance_request_params)
      fire_event
      redirect_to balance_requests_path if @balance_request.errors.empty?
    end

    private

    def find_balance_request
      @balance_request = BalanceRequest.find(params[:id])
    end

    def balance_request_params
      params.require(:balance_request).permit(:id, :user_id, :requests_type, :amount, :crypto_address, :short_comment)
    end
  end
end
