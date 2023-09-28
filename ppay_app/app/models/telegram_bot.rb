# frozen_string_literal: true

class TelegramBot < ApplicationRecord
  after_validation :add_at_symbol_to_name

  has_and_belongs_to_many :telegram_applications, join_table: 'telegram_applications_bots'

  validates :name, presence: true, uniqueness: true, format: { with: /\A@[^@]+\z/ }

  private

  def add_at_symbol_to_name
    self.name = "@#{name}" unless name&.start_with?('@')
  end
end
