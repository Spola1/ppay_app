# frozen_string_literal: true

class TelegramConnection < ApplicationRecord
  belongs_to :processer
  validates :status, presence: true
end