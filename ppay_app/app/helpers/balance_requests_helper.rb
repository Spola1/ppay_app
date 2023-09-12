# frozen_string_literal: true

module BalanceRequestsHelper
  def balance_request_filters_params(key)
    params[:balance_request_filters][key] if params[:balance_request_filters]
  end

  def balance_requests_commission
    if national_balance?
      RateSnapshot.recent_buy_by_national_currency_name(current_user.balance.currency).value * \
        Setting.instance.balance_requests_commission
    else
      Setting.instance.balance_requests_commission
    end
  end

  def balance_request_table_amounts(balance_request)
    balance_request.amount.to_s +
      (balance_request.amount_minus_commission.present? ? " (#{balance_request.amount_minus_commission}) " : ' ') +
      balance_request.user.balance.currency.to_s
  end
end
