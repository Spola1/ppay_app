# frozen_string_literal: true

class Setting < ApplicationRecord
  store_accessor :settings, :version, :commissions_version,
                 :equal_amount_payments_limit

  # Метод, который возвращает или создает новую запись настроек
  def self.instance
    first_or_create(receive_requests_enabled: false)
  end

  def commissions_version=(value)
    super(value.to_i)
  end

  def equal_amount_payments_limit=(value)
    super(value.to_i)
  end
end
