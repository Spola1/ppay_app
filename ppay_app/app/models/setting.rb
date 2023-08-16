# frozen_string_literal: true

class Setting < ApplicationRecord
  store_accessor :settings, :version
  store_accessor :settings, :commissions_version

  # Метод, который возвращает или создает новую запись настроек
  def self.instance
    first_or_create(receive_requests_enabled: false)
  end

  def commissions_version = super.to_i
end
