# frozen_string_literal: true

class Payment < ApplicationRecord
  include CardNumberSettable
  include DateFilterable
  include Filterable
  include EnumValidatable

  audited

  default_scope { order(created_at: :desc, id: :desc) }
  scope :filter_by_created_from, ->(created_from) { where('payments.created_at > ?', created_from) }
  scope :filter_by_created_to, ->(created_to) { where('payments.created_at < ?', created_to) }
  scope :filter_by_cancellation_reason, ->(cancellation_reason) { where(cancellation_reason:) }
  scope :filter_by_payment_status, ->(payment_status) { where(payment_status:) }
  scope :filter_by_payment_system, ->(payment_system) { where(payment_system:) }
  scope :filter_by_national_currency, ->(national_currency) { where(national_currency:) }
  scope :filter_by_uuid, ->(uuid) { where('uuid::text LIKE ?', "%#{uuid}%") }
  scope :filter_by_external_order_id, ->(external_order_id) { where(external_order_id:) }
  scope :filter_by_national_currency_amount_from,
        ->(national_currency_amount) { where 'national_currency_amount > ?', national_currency_amount }
  scope :filter_by_national_currency_amount_to,
        ->(national_currency_amount) { where 'national_currency_amount < ?', national_currency_amount }
  scope :filter_by_cryptocurrency_amount_from,
        ->(cryptocurrency_amount) { where 'cryptocurrency_amount > ?', cryptocurrency_amount }
  scope :filter_by_cryptocurrency_amount_to,
        ->(cryptocurrency_amount) { where 'cryptocurrency_amount < ?', cryptocurrency_amount }

  enum cancellation_reason: {
    by_client: 0,
    duplicate_payment: 1,
    fraud_attempt: 2,
    incorrect_amount: 3,
    not_paid: 4,
    time_expired: 5
  }
  enum processing_type: { internal: 0, external: 1 }
  enum unique_amount: {
    none: 0,
    integer: 1,
    decimal: 2
  }, _prefix: true

  has_many :transactions, as: :transactionable

  # в каждый платеж прикрепляем курс на данный момент
  # это обязательно
  belongs_to :rate_snapshot, optional: true
  belongs_to :advertisement, optional: true
  belongs_to :support, optional: true

  # обязательная связь (с моделью STI - merchant < user)
  belongs_to :merchant, optional: true

  delegate :processer, to: :advertisement, allow_nil: true

  has_one_attached :image

  has_many :comments, as: :commentable
  has_many :chats

  before_create :set_default_unique_amount, unless: :unique_amount
  before_create :set_initial_amount

  before_save :set_support, if: -> { support.blank? && arbitration_changed? && arbitration }

  before_save :take_off_arbitration, if: -> { payment_status.in?(%w[cancelled completed]) && payment_status_changed? }
  before_save :complete_transactions, if: -> { payment_status.in?(%w[completed]) && payment_status_changed? }
  before_save :cancel_transactions, if: -> { payment_status.in?(%w[cancelled]) && payment_status_changed? }

  validates_presence_of :payment_system, if: :external?
  validates_presence_of :card_number, if: -> { external? && type == 'Withdrawal' }
  validates_presence_of :national_currency, :national_currency_amount, :callback_url
  validates_presence_of :redirect_url, if: :internal?

  validates :national_currency, inclusion: { in: Settings.national_currencies,
                                             valid_values: Settings.national_currencies.join(', ') }

  validate :transactions_cannot_be_completed_or_cancelled, if: -> { payment_status_changed? }

  validates :unique_amount, inclusion: { in: unique_amounts.keys.push(nil),
                                         valid_values: unique_amounts.keys.join(', ') }
  validatable_enum :unique_amount

  after_update_commit lambda {
    broadcast_replace_payment_to_client if payment_status_previously_changed? || arbitration_previously_changed?
    broadcast_replace_payment_to_processer
    broadcast_replace_payment_to_support
  }

  after_update_commit lambda {
    if payment_status_previously_changed? && processer
      broadcast_replace_hotlist_to_processer
      broadcast_append_notification_to_processer if in_hotlist?
    end
  }

  after_update_commit -> { Payments::UpdateCallbackJob.perform_async(id) if payment_status_previously_changed? }

  scope :in_hotlist, lambda {
    deposits.confirming.or(withdrawals.transferring).order(status_changed_at: :desc)
  }
  scope :deposits,    -> { where(type: 'Deposit') }
  scope :withdrawals, -> { where(type: 'Withdrawal') }
  scope :expired,     -> { where('status_changed_at < ?', 20.minutes.ago) }
  scope :arbitration, -> { where(arbitration: true) }
  scope :active,      -> { where.not(payment_status: %w[completed cancelled]) }

  %i[created draft processer_search transferring confirming completed cancelled].each do |status|
    scope status, -> { where(payment_status: status) }
  end

  def signature
    data = { national_currency:, initial_amount:, external_order_id: }.to_json

    OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), merchant.api_keys.last.token, data)
  end

  private

  def set_support
    self.support = Support.all.sample
  end

  def in_hotlist?
    (type == 'Deposit' && confirming?) || (type == 'Withdrawal' && transferring?)
  end

  def take_off_arbitration
    self.arbitration = false
  end

  def broadcast_replace_payment_to_client
    broadcast_replace_later_to(
      "payment_#{uuid}",
      partial: 'payments/show_turbo_frame',
      locals: { payment: decorate, signature: },
      target: "payment_#{uuid}"
    )
  end

  def broadcast_replace_payment_to_processer
    broadcast_replace_later_to(
      "processers_payment_#{uuid}",
      partial: 'processers/payments/show_turbo_frame',
      locals: { payment: decorate, signature: nil, role_namespace: 'processers', can_manage_payment?: true },
      target: "processers_payment_#{uuid}"
    )
  end

  def broadcast_replace_hotlist_to_processer
    broadcast_replace_later_to(
      "processer_#{processer.id}_hotlist",
      partial: 'processers/payments/hotlist',
      locals: { role_namespace: 'processers', user: processer },
      target: "processer_#{processer.id}_hotlist"
    )
  end

  def broadcast_append_notification_to_processer
    notify_service = TelegramNotificationService.new(uuid, national_currency_amount, card_number)

    unless processer.telegram_id.present?
      telegram_id = notify_service.get_user_id(processer.telegram)
      processer.update(telegram_id: telegram_id) if telegram_id.present?
    end

    notify_service.send_notification_to_user(processer.telegram_id)

    broadcast_append_later_to(
      "processer_#{processer.id}_notifications",
      partial: 'processers/notifications/notification',
      locals: { payment: decorate, role_namespace: 'processers', user: processer },
      target: "processer_#{processer.id}_notifications"
    )
  end

  def broadcast_replace_payment_to_support
    broadcast_replace_later_to(
      "supports_payment_#{uuid}",
      partial: 'supports/payments/show_turbo_frame',
      locals: { payment: decorate, signature: nil, role_namespace: 'supports', can_manage_payment?: true },
      target: "supports_payment_#{uuid}"
    )
  end

  def set_default_unique_amount
    self.unique_amount = merchant.unique_amount
  end

  def set_initial_amount
    self.initial_amount = national_currency_amount
  end

  def transactions_cannot_be_completed_or_cancelled
    return if transactions.pluck(:status).all?('frozen')

    errors.add(:transactions, 'already completed or cancelled')
  end
end
