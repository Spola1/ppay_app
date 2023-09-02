# frozen_string_literal: true

class MerchantDecorator < UserDecorator
  delegate_all

  def turnover(filtering_params)
    if balance.in_national_currency
      full_currency_turnover(filtering_params, :national_currency)
    else
      full_currency_turnover(filtering_params, :cryptocurrency)
    end
  end

  def deposits_turnover(filtering_params)
    if balance.in_national_currency
      currency_turnover(filtering_params, :deposits, :national_currency)
    else
      currency_turnover(filtering_params, :deposits, :cryptocurrency)
    end
  end

  def withdrawals_turnover(filtering_params)
    if balance.in_national_currency
      currency_turnover(filtering_params, :withdrawals, :national_currency)
    else
      currency_turnover(filtering_params, :withdrawals, :cryptocurrency)
    end
  end

  private

  def full_currency_turnover(filtering_params, currency)
    payments.filter_by(filtering_params).completed.sum("#{currency}_amount").to_f
  end

  def currency_turnover(filtering_params, payment_type, currency)
    public_send(payment_type).filter_by(filtering_params).completed.sum("#{currency}_amount").to_f
  end
end
