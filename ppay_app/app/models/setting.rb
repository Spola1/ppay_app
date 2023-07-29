# frozen_string_literal: true

class Setting < ApplicationRecord
  # Метод, который возвращает или создает новую запись настроек
  def self.instance
    first_or_create(receive_requests_enabled: false)
  end
end
