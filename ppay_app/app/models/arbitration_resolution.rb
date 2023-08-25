# frozen_string_literal: true

class ArbitrationResolution < ApplicationRecord
  belongs_to :payment

  enum reason: {
    duplicate_payment: 0,
    fraud_attempt: 1,
    incorrect_amount: 2,
    not_paid: 3,
    time_expired: 4,
    check_by_check: 5,
    incorrect_amount_check: 6,
    reason_in_chat: 7
  }, _prefix: true

  validates_presence_of :reason

  scope :completed, -> { where.not(ended_at: nil) }
end
