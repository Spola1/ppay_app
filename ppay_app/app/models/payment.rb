# frozen_string_literal: true

class Payment < ApplicationRecord
  include CardNumberSettable
  include DateFilterable
  include Filterable
  include EnumValidatable
  include Payments::Filterable

  audited

  default_scope { order(created_at: :desc, id: :desc) }

  scope :expired_arbitration_not_paid, lambda {
    where(arbitration: true,
          arbitration_reason: :not_paid)
  }
  scope :expired_autoconfirming, lambda {
    where(autoconfirming: true, payment_status: :confirming)
      .where('status_changed_at <= ?', Setting.last.minutes_to_autocancel.minutes.ago)
  }
  scope :finished, -> { where(payment_status: %w[cancelled completed]) }

  enum cancellation_reason: {
    by_client: 0,
    duplicate_payment: 1,
    fraud_attempt: 2,
    incorrect_amount: 3,
    not_paid: 4,
    time_expired: 5
  }
  enum arbitration_reason: {
    duplicate_payment: 0,
    fraud_attempt: 1,
    incorrect_amount: 2,
    not_paid: 3,
    time_expired: 4,
    check_by_check: 5,
    incorrect_amount_check: 6,
    reason_in_chat: 7
  }, _prefix: true
  enum processing_type: {
    internal: 0,
    external: 1
  }
  enum unique_amount: {
    none: 0,
    integer: 1,
    decimal: 2
  }, _prefix: true
  enum advertisement_not_found_reason: {
    no_active_advertisements: 0,
    equal_amount_payments_limit_exceeded: 1
  }, _prefix: true

  has_many :transactions, as: :transactionable

  has_many :arbitration_resolutions

  has_many :payment_receipts, dependent: :destroy

  # в каждый платеж прикрепляем курс на данный момент
  # это обязательно
  belongs_to :rate_snapshot, optional: true
  belongs_to :advertisement, optional: true
  belongs_to :support, optional: true

  # обязательная связь (с моделью STI - merchant < user)
  belongs_to :merchant, optional: true

  delegate :processer, to: :advertisement, allow_nil: true

  has_one_attached :image
  belongs_to :form_customization, optional: true

  has_many :comments, as: :commentable
  has_many :chats

  before_create :set_default_unique_amount
  before_create :set_initial_amount
  before_create :set_locale_from_currency

  before_save :set_support, if: -> { support.blank? && arbitration_changed? && arbitration }

  before_save :take_off_arbitration, if: -> { payment_status.in?(%w[cancelled completed]) && payment_status_changed? }
  before_save :update_status_changed_at, if: :payment_status_changed?

  validates_presence_of :card_number, if: -> { external? && type == 'Withdrawal' }
  validates_presence_of :national_currency, :national_currency_amount, :callback_url
  validates_presence_of :redirect_url, if: :internal?

  validates :national_currency, inclusion: { in: proc { NationalCurrency.pluck(:name) },
                                             valid_values: proc { NationalCurrency.pluck(:name).join(', ') } }
  validate :transactions_cannot_be_completed_or_cancelled, if: -> { payment_status_changed? }

  validates :unique_amount, inclusion: { in: unique_amounts.keys.push(nil),
                                         valid_values: unique_amounts.keys.join(', ') }
  validatable_enum :unique_amount

  validate :validate_arbitration_fields, on: :merchant

  before_save :update_arbitration_resolutions_time, if: :arbitration_changed?

  after_update_commit :complete_transactions, if: lambda {
    payment_status.in?(%w[completed]) && payment_status_previously_changed?
  }
  after_update_commit :cancel_transactions, if: lambda {
    payment_status.in?(%w[cancelled]) && payment_status_previously_changed?
  }

  after_update_commit lambda {
    broadcast_replace_payment_to_client if payment_status_previously_changed? || arbitration_previously_changed?
    broadcast_arbitrations_by_check_count if arbitration_previously_changed? || arbitration_reason_previously_changed?
    broadcast_replace_payment_to_processer
    broadcast_replace_payment_to_support
    broadcast_replace_payment_to_merchant
  }

  after_update_commit lambda {
    if payment_status_previously_changed? && processer
      broadcast_replace_hotlist_to_processer
      broadcast_append_notification_to_processer if in_hotlist?
    end
  }

  after_update_commit lambda {
    if (payment_status_previously_changed? || autoconfirming_previously_changed?) && processer
      broadcast_replace_ad_hotlist_to_processer
    end
  }

  after_update_commit -> { Payments::UpdateCallbackJob.perform_async(id) if payment_status_previously_changed? }

  after_update_commit :send_arbitration_notification, if: :arbitration_changed_to_true?

  after_update_commit :create_initial_chat_message, if: :not_paid_cancellation_reason_changed?

  scope :in_hotlist, lambda {
    deposits.confirming.or(withdrawals.transferring).reorder(created_at: :desc)
  }

  scope :for_simbank, lambda {
    deposits.confirming.or(deposits.transferring).reorder(created_at: :desc)
  }

  scope :in_deposit_flow_hotlist, lambda {
    deposits.confirming # .where(autoconfirming: false)
            .or(deposits.transferring)
            .or(deposits.arbitration)
            .reorder(Arel.sql(("arbitration ASC, CASE WHEN payment_status = 'confirming' THEN 0 ELSE 1 END, status_changed_at DESC")))
  }

  scope :in_withdrawal_flow_hotlist, lambda {
    withdrawals.confirming
               .or(withdrawals.transferring)
               .or(withdrawals.arbitration)
               .reorder(Arel.sql(("arbitration ASC, CASE WHEN payment_status = 'confirming' THEN 1 ELSE 0 END, status_changed_at DESC")))
  }

  scope :arbitration_by_check, lambda {
    where(arbitration: true, arbitration_reason: [5, 6])
  }

  scope :deposits,    -> { where(type: 'Deposit') }
  scope :withdrawals, -> { where(type: 'Withdrawal') }
  scope :arbitration, -> { where(arbitration: true) }
  scope :active,      -> { where.not(payment_status: %w[completed cancelled]) }
  scope :expired,     lambda {
    joins(:merchant).where(
      "CASE WHEN users.differ_ftd_and_other_payments = TRUE AND payments.initial_amount = users.ftd_payment_default_summ
        THEN (payments.status_changed_at + INTERVAL '1 second' * users.ftd_payment_exec_time_in_sec)
      ELSE (payments.status_changed_at + INTERVAL '1 second' * users.regular_payment_exec_time_in_sec)
      END < NOW()"
    )
  }

  %i[created draft processer_search transferring confirming completed cancelled].each do |status|
    scope status, -> { where(payment_status: status) }
  end

  def advertisement=(value)
    super(value)

    self.advertisement_not_found_reason = value.present? ? nil : :no_active_advertisements
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

  def broadcast_replace_payment_to_processer
    broadcast_replace_later_to(
      "processers_payment_#{uuid}",
      partial: 'processers/payments/show_turbo_frame',
      locals: { payment: decorate, signature: nil, role_namespace: 'processers', can_manage_payment?: true },
      target: "processers_payment_#{uuid}"
    )
  end

  def broadcast_replace_payment_to_merchant
    broadcast_replace_later_to(
      "merchant_payment_#{uuid}",
      partial: 'merchants/payments/show_turbo_frame',
      locals: { payment: decorate, signature: nil, role_namespace: 'merchants', can_manage_payment?: true },
      target: "merchants_payment_#{uuid}"
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

  def arbitration_changed_to_true?
    saved_change_to_arbitration? && arbitration?
  end

  def advertisements_available?
    Advertisement.for_payment(self).exists?
  end

  def equal_amount_limited_advertisements_available?
    return advertisements_available? unless merchant.equal_amount_payments_limit

    advertisements_scope
      .equal_amount_payments_limited(national_currency_amount, merchant.equal_amount_payments_limit)
      .exists?
  end

  private

  def advertisements_scope
    Advertisement.public_send("for_#{type.downcase}", self)
  end

  def update_arbitration_resolutions_time
    if arbitration
      arbitration_resolutions.create(reason: arbitration_reason)
    else
      last_resolution = arbitration_resolutions.last
      last_resolution.update(ended_at: Time.current) if last_resolution.present?
    end
  end

  def create_initial_chat_message
    text_with_active_arbitration_chat = "Здравствуйте, для подтверждения перевода\n загрузите скриншот чека на котором указаны:\n
            \n1. Сумма платежа\n2. Дата и время платежа\n3. Карта получателя\n \nПосле загрузки чека у Вас появится\n
            возможность писать сообщения в чате"

    text_without_active_arbitration_chat = "Здравствуйте, для подтверждения перевода\n загрузите скриншот чека на котором указаны:\n
            \n1. Сумма платежа\n2. Дата и время платежа\n3. Карта получателя\n"

    if merchant.chat_enabled?
      Chat.create(payment_id: id, user_id: support_id, text: text_with_active_arbitration_chat)
    else
      Chat.create(payment_id: id, user_id: support_id, text: text_without_active_arbitration_chat)
    end
  end

  def not_paid_cancellation_reason_changed?
    saved_change_to_cancellation_reason? && cancellation_reason == 'not_paid'
  end

  def send_arbitration_notification
    Payments::TelegramNotificationJob.perform_async(id, attribute_was(:arbitration), nil, nil)
  end

  def validate_arbitration_fields
    return unless arbitration?

    errors.add(:arbitration_reason, "can't be blank") if arbitration_reason.blank?
    errors.add(:image, "can't be blank") if image.blank?
  end

  def set_locale_from_currency
    self.locale = currency_to_locale(national_currency) if locale.blank?
  end

  def currency_to_locale(national_currency)
    currency_to_locale_map = {
      'RUB' => :ru, 'UZS' => :uz, 'TJS' => :tg, 'IDR' => :id,
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

  def broadcast_append_notification_to_processer
    Payments::TelegramNotificationJob.perform_async(id, false, nil, nil)

    broadcast_append_later_to(
      "processer_#{processer.id}_notifications",
      partial: 'processers/notifications/notification',
      locals: { payment: decorate, role_namespace: 'processers', user: processer },
      target: "processer_#{processer.id}_notifications"
    )
  end

  def broadcast_arbitrations_by_check_count
    if processer
      broadcast_replace_later_to(
        "processer_#{processer.id}_arbitration_count",
        partial: 'shared/arbitration_count_turbo_frame',
        locals: { count: processer.payments.arbitration_by_check.count, user: processer },
        target: "processer_#{processer.id}_arbitration_count"
      )
    end
    if merchant
      broadcast_replace_later_to(
        "merchant_#{merchant.id}_arbitration_count",
        partial: 'shared/arbitration_count_turbo_frame',
        locals: { count: merchant.payments.arbitration_by_check.count, user: merchant },
        target: "merchant_#{merchant.id}_arbitration_count"
      )
    end
    broadcast_replace_later_to(
      'support_arbitration_count',
      partial: 'shared/support_arbitration_count_turbo_frame',
      locals: { count: Payment.arbitration_by_check.count },
      target: 'support_arbitration_count'
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
