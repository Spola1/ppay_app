# frozen_string_literal: true

module Merchants

  class BalanceRequestsController < BaseController
    def index
      @pagy, @balance_requests = pagy(current_user.balance_requests)
    end

    def show
      @balance_request = BalanceRequest.find(params[:id])
    end

    def new
      @balance_request = current_user.balance_requests.new
    end

    def edit
      @balance_request = current_user.balance_requests.find(params[:id])
    end

    def create
      @balance_request = current_user.balance_requests.new(balance_request_params)
      @balance_request.user = current_user
      if @balance_request.save
        redirect_to @balance_request
      else
        # error
      end
    end

    def update
      @balance_request = current_user.balance_requests.find(params[:id])
      @balance_request.update(balance_request_params)
      redirect_to balance_requests_path if @balance_request.errors.empty?
    end

    def destroy; end

    private

    def balance_request_params
      params.require(:balance_request).permit(:id, :user_id, :requests_type, :amount, :status,
                                            :crypto_address)
    end
  end
end


