# frozen_string_literal: true

class Chat < ApplicationRecord
  belongs_to :payment
  belongs_to :user, optional: true

  validates_presence_of :text

  after_create_commit :send_new_chat_notification

  private

  def send_new_chat_notification
    return unless payment.arbitration_changed? || payment.arbitration?

    Payments::TelegramNotificationJob.perform_async(payment.id, payment.arbitration_was, text, nil)
  end
end
