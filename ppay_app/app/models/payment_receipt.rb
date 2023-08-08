# frozen_string_literal: true

class PaymentReceipt < ApplicationRecord
  belongs_to :payment
  has_one_attached :image

  validates :image, presence: true
  validates :source, presence: true

  enum receipt_reason: {
    duplicate_payment: 0,
    fraud_attempt: 1,
    incorrect_amount: 2,
    not_paid: 3,
    time_expired: 4,
    check_by_check: 5,
    incorrect_amount_check: 6
  }, _prefix: true
  enum source: {
    merchant_dashboard: 0,
    hpp_form: 1,
    merchant_service: 2
  }, _prefix: true

  after_create_commit :set_arbitration

  private

  def set_arbitration
    if receipt_reason.present? && payment.arbitration?
      payment.update(arbitration_reason: receipt_reason)
    elsif receipt_reason.nil? && payment.arbitration?
      payment.update(arbitration_reason: payment.arbitration_reason)
    elsif receipt_reason.present? && !payment.arbitration?
      payment.update(arbitration: true, arbitration_reason: receipt_reason)
    else
      payment.update(arbitration: true)
    end
  end
end
