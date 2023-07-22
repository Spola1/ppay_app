# frozen_string_literal: true

class MerchantDecorator < UserDecorator
  delegate_all

  def turnover(filtering_params)
    if balance.in_national_currency
      national_currency_turnover(filtering_params)
    else
      cryptocurrency_turnover(filtering_params)
    end
  end

  private

  def cryptocurrency_turnover(filtering_params)
    payments.filter_by(filtering_params).completed.sum(:cryptocurrency_amount).to_f
  end

  def national_currency_turnover(filtering_params)
    payments.filter_by(filtering_params).completed.sum(:national_currency_amount).to_f
  end
end
