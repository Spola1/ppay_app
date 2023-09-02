# frozen_string_literal: true

module TelegramProcessable
  extend ActiveSupport::Concern

  included do
    before_validation :process_telegram, if: -> { telegram.present? }
    validates :telegram, format: { with: /\A@?\w+\z/ }, allow_blank: true
    validate :telegram_id_presence, if: -> { telegram.present? }
  end

  private

  def process_telegram
    return unless telegram.present?

    telegram.gsub!(/^@/, '')
    notify_service = TelegramNotification::GetUserIdService.new(telegram)
    self.telegram_id = notify_service.get_user_id(telegram)
  end

  def telegram_id_presence
    return unless telegram_changed?

    errors.add(:telegram, :not_found) unless telegram_id.present?
  end
end
