# frozen_string_literal: true

module BalanceRequestsHelper
  def balance_request_filters_params(key)
    params[:balance_request_filters][key] if params[:balance_request_filters]
  end
end
