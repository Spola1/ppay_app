# frozen_string_literal: true

class Payment < ApplicationRecord
  include CardNumberSettable
  include DateFilterable

  default_scope { order(created_at: :desc) }

  has_many :transactions

  # в каждый платеж прикрепляем курс на данный момент
  # это обязательно
  belongs_to :rate_snapshot, optional: true
  belongs_to :advertisement, optional: true
  belongs_to :support, optional: true

  #обязательная связь (с моделью STI - merchant < user)
  belongs_to :merchant, optional: true

  delegate :processer, to: :advertisement, :allow_nil => true

  has_one_attached :image

  has_many :comments, as: :commentable

  before_save :set_support, if: -> { support.blank? && arbitration_changed? && arbitration }

  validates :national_currency, inclusion: { in: Settings.national_currencies,
                                             valid_values: Settings.national_currencies.join(', ') }

  after_update_commit -> do
    broadcast_replace_payment_to_client
    broadcast_replace_payment_to_processer
    broadcast_replace_payment_to_support
  end

  after_update_commit -> do
    if payment_status_previously_changed? && processer
      broadcast_replace_hotlist_to_processer
      broadcast_append_notification_to_processer if in_hotlist?
    end
  end

  scope :in_hotlist, -> do
    deposits.confirming.or(withdrawals.transferring).order(status_changed_at: :desc)
  end
  scope :deposits,    -> { where(type: 'Deposit') }
  scope :withdrawals, -> { where(type: 'Withdrawal') }
  scope :expired,     -> { where('status_changed_at < ?', 20.minutes.ago) }

  %i[created draft processer_search transferring confirming completed cancelled].each do |status|
    scope status, -> { where(payment_status: status) }
  end

  def signature
    data = { national_currency:, national_currency_amount:, external_order_id: }.to_json

    OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), merchant.api_keys.last.token, data)
  end

  private

  def set_support
    self.support = Support.all.sample
  end

  def in_hotlist?
    type == 'Deposit' && confirming? || type == 'Withdrawal' && transferring?
  end

  def broadcast_replace_payment_to_client
    broadcast_replace_to(
      "payment_#{ self.uuid }",
      partial: "payments/show_turbo_frame",
      locals: { payment: self.decorate, signature: self.signature },
      target: "payment_#{ self.uuid }"
    )
  end

  def broadcast_replace_payment_to_processer
    broadcast_replace_to(
      "processers_payment_#{ self.uuid }",
      partial: "processers/payments/show_turbo_frame",
      locals: { payment: self.decorate, signature: nil, role_namespace: 'processers' },
      target: "processers_payment_#{ self.uuid }"
    )
  end

  def broadcast_replace_hotlist_to_processer
    broadcast_replace_to(
      "processer_#{processer.id}_hotlist",
      partial: "processers/payments/hotlist",
      locals: { role_namespace: 'processers', user: processer },
      target: "processer_#{processer.id}_hotlist"
    )
  end

  def broadcast_append_notification_to_processer
    broadcast_append_to(
      "processer_#{processer.id}_notifications",
      partial: "processers/notifications/notification",
      locals: { payment: self.decorate, role_namespace: 'processers', user: processer },
      target: "processer_#{processer.id}_notifications"
    )
  end

  def broadcast_replace_payment_to_support
    broadcast_replace_to(
      "supports_payment_#{ self.uuid }",
      partial: "supports/payments/show_turbo_frame",
      locals: { payment: self.decorate, signature: nil, role_namespace: 'supports' },
      target: "supports_payment_#{ self.uuid }"
    )
  end
end
