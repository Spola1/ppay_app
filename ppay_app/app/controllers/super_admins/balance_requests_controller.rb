# frozen_string_literal: true

module SuperAdmins
  class BalanceRequestsController < Staff::Management::BalanceRequestsController
    def index
      @pagy, @balance_requests = pagy(
        BalanceRequest.joins(:user).includes(user: :balance)
          .filter_by(filtering_params)
          .order(created_at: :desc)
      )
    end
  end
end
