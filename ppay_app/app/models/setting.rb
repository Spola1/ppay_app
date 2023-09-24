# frozen_string_literal: true

class Setting < ApplicationRecord
  store_accessor :settings, :version, :commissions_version, :balance_requests_commission,
                 :otp_payment_confirm_amount

  # Метод, который возвращает или создает новую запись настроек
  def self.instance
    first_or_create(receive_requests_enabled: false)
  end

  def commissions_version=(value)
    super(value.to_i)
  end

  def otp_payment_confirm_amount=(value)
    super(value.to_f)
  end
end
