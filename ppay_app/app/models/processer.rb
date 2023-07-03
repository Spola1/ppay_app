# frozen_string_literal: true

class Processer < User
  has_many :advertisements, foreign_key: :processer_id
  has_many :payments, through: :advertisements
  has_many :deposits, through: :advertisements
  has_many :withdrawals, through: :advertisements

  belongs_to :working_group, optional: true

  before_validation :process_telegram

  validates :telegram, format: { with: /\A@?\w+\z/ }, allow_blank: true
  validate :telegram_id_presence, if: -> { telegram.present? }

  private

  def process_telegram
    return unless telegram.present?

    telegram.gsub!(/^@/, '')
    notify_service = TelegramNotification::GetUserIdService.new(telegram)
    self.telegram_id = notify_service.get_user_id(telegram)
  end

  def telegram_id_presence
    errors.add(:telegram, :not_found) unless telegram_id.present?
  end
end
