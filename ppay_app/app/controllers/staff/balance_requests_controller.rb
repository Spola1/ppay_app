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
        redirect_to balance_request_path(@balance_request)
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      fire_event

      redirect_to balance_requests_path if @balance_request.errors.empty?
    end

    def balance_requests_commission
      return 0 unless Setting.instance.balance_requests_commission

      if current_user.balance.in_national_currency?
        RateSnapshot.recent_buy_by_national_currency_name(current_user.balance.currency).value * \
          Setting.instance.balance_requests_commission
      else
        Setting.instance.balance_requests_commission
      end
    end
    helper_method :balance_requests_commission

    private

    def find_balance_request
      @balance_request = current_user.balance_requests.find(params[:id])
    end

    def balance_request_params
      params.require(:balance_request)
            .permit(:requests_type, :amount, :crypto_address, :amount_minus_commission)
            .tap do |permitted|
              next if permitted[:requests_type] == 'deposit'

              permitted[:amount_minus_commission] = [permitted[:amount].to_f - balance_requests_commission, 0].max
            end
    end
  end
end
