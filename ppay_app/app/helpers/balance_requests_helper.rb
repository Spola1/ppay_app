# frozen_string_literal: true

module BalanceRequestsHelper
  def balance_request_filters_params(key)
    params[:balance_request_filters][key] if params[:balance_request_filters]
  end

  def balance_request_table_amounts(balance_request)
    balance_request.amount.to_s +
      (balance_request.amount_minus_commission.present? ? " (#{balance_request.amount_minus_commission}) " : ' ') +
      balance_request.user.balance.currency.to_s
  end
end
