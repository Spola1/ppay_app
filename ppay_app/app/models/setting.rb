# frozen_string_literal: true

class Setting < ApplicationRecord
  validates :receive_requests_enabled, inclusion: { in: [true, false] }

  # Метод, который возвращает или создает новую запись настроек
  def self.instance
    first_or_create(receive_requests_enabled: false)
  end
end