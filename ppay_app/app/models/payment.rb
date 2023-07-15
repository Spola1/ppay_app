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
  before_create :set_locale_from_currency

  before_save :set_support, if: -> { support.blank? && arbitration_changed? && arbitration }

  before_save :take_off_arbitration, if: -> { payment_status.in?(%w[cancelled completed]) && payment_status_changed? }
  before_save :complete_transactions, if: -> { payment_status.in?(%w[completed]) && payment_status_changed? }
  before_save :cancel_transactions, if: -> { payment_status.in?(%w[cancelled]) && payment_status_changed? }

  validates_presence_of :payment_system, if: :external?
  validates_presence_of :card_number, if: -> { external? && type == 'Withdrawal' }
  validates_presence_of :national_currency, :national_currency_amount, :callback_url
  validates_presence_of :redirect_url, if: :internal?

  validates :national_currency, inclusion: { in: proc { NationalCurrency.pluck(:name) },
                                             valid_values: proc { NationalCurrency.pluck(:name).join(', ') } }
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
      broadcast_replace_hotlist_to_ad
      broadcast_replace_ad_hotlist_to_processer
      broadcast_append_notification_to_processer if in_hotlist?
    end
  }

  after_update_commit -> { Payments::UpdateCallbackJob.perform_async(id) if payment_status_previously_changed? }

  scope :in_hotlist, lambda {
    deposits.confirming.or(withdrawals.transferring).order(created_at: :desc)
  }

  scope :in_flow_hotlist, lambda {
    deposits.confirming
           .or(deposits.transferring)
           .or(deposits.arbitration)
           .or(withdrawals.confirming)
           .or(withdrawals.transferring)
           .or(withdrawals.arbitration)
           .order(Arel.sql(("arbitration ASC, CASE WHEN payment_status = 'confirming' THEN 0 ELSE 1 END, status_changed_at DESC")))
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

  def language_from_locale
    language_mapping = {
      'ru' => 'ru-ru',
      'uk' => 'uk-ua',
      'uz' => 'uz-uz',
      'tg' => 'tg-tg',
      'id' => 'id-id',
      'kk' => 'kk-kk',
      'tr' => 'tr-tr',
      'ky' => 'ky-ky'
    }

    language_mapping[locale] || 'ru-ru'
  end

  private

  def set_locale_from_currency
    self.locale = currency_to_locale(national_currency) if locale.blank?
  end

  def currency_to_locale(national_currency)
    currency_to_locale_map = {
      'RUB' => :ru, 'UZS' => :uz, 'TJS' => :tg, 'IDR' => :ru,
      'KZT' => :kk, 'UAH' => :uk, 'TRY' => :tr, 'KGS' => :ky
    }

    currency_to_locale_map[national_currency] || I18n.default_locale.to_s
  end

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

  def broadcast_replace_ad_hotlist_to_processer
    broadcast_replace_later_to(
      "processer_#{processer.id}_ad_hotlist",
      partial: 'processers/advertisements/ad_hotlist',
      locals: { role_namespace: 'processers', user: processer },
      target: "processer_#{processer.id}_ad_hotlist"
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

  def broadcast_replace_hotlist_to_ad
    broadcast_replace_later_to(
      "advertisement_#{advertisement.id}_hotlist",
      partial: 'processers/advertisements/hotlist',
      locals: { advertisement: advertisement, payment: decorate },
      target: "advertisement_#{advertisement.id}_hotlist"
    )
  end

  def broadcast_append_notification_to_processer
    Payments::TelegramNotificationJob.perform_async(id)

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
