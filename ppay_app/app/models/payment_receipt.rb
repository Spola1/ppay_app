# frozen_string_literal: true

class PaymentReceipt < ApplicationRecord
  belongs_to :payment
  belongs_to :user, optional: true
  has_one_attached :image

  with_options unless: :user_support? do
    validates :image, presence: true
  end

  validates :source, presence: true
  validates :receipt_reason, presence: true, if: :start_arbitration?

  enum receipt_reason: {
    duplicate_payment: 0,
    fraud_attempt: 1,
    incorrect_amount: 2,
    not_paid: 3,
    time_expired: 4,
    check_by_check: 5,
    incorrect_amount_check: 6,
    reason_in_chat: 7
  }, _prefix: true
  enum source: {
    merchant_dashboard: 0,
    hpp_form: 1,
    merchant_service: 2,
    support_dashboard: 3
  }, _prefix: true

  after_create_commit :set_arbitration, if: :start_arbitration?
  after_create_commit :broadcast_replace_ad_hotlist_to_processer

  private

  def user_support?
    user&.support?
  end

  def set_arbitration
    payment.update(arbitration_reason: receipt_reason, arbitration: true)
  end

  def broadcast_replace_ad_hotlist_to_processer
    broadcast_replace_later_to(
      "processer_#{payment.processer.id}_ad_hotlist",
      partial: 'processers/advertisements/ad_hotlist',
      locals: { role_namespace: 'processers', user: payment.processer },
      target: "processer_#{payment.processer.id}_ad_hotlist"
    )
  end
end
