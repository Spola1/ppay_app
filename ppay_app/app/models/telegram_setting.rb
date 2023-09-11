# frozen_string_literal: true

class TelegramSetting < ApplicationRecord
  belongs_to :user
end
