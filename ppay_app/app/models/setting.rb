# frozen_string_literal: true

class Setting < ApplicationRecord
  store_accessor :settings, :version, :commissions_version

  # Метод, который возвращает или создает новую запись настроек
  def self.instance
    first_or_create(receive_requests_enabled: false)
  end
end
