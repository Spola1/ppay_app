# frozen_string_literal: true

module Staff
  class BalanceRequestsController < Staff::BaseController
    include Staff::BalanceRequests::EventFireable

    STATUS_EVENTS_MAPPING = {
      'Отменён' => :cancel
    }.freeze

    before_action :find_balance_request, except: %i[new create index]

    def index
      @pagy, @balance_requests = pagy(current_user.balance_requests.order(created_at: :desc))
    end

    def show
      @balance_request = current_user.balance_requests.find(params[:id])
    end

    def new
      @balance_request = current_user.balance_requests.new
    end

    def create
      @balance_request = current_user.balance_requests.new(balance_request_params)

      if @balance_request.save
        redirect_to balance_request_path(@balance_request)  # @balance_request
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      fire_event

      redirect_to balance_requests_path if @balance_request.errors.empty?
    end

    private

    def find_balance_request
      @balance_request = current_user.balance_requests.find(params[:id])
    end

    def balance_request_params
      params.require(:balance_request).permit(:requests_type, :amount, :crypto_address)
    end
  end
end
