# frozen_string_literal: true

class TelegramApplication < ApplicationRecord
  belongs_to :processer
  has_and_belongs_to_many :telegram_bots
end
