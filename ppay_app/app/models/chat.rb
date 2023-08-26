# frozen_string_literal: true

class Chat < ApplicationRecord
  attr_accessor :skip_notification

  belongs_to :payment
  belongs_to :user, optional: true
  has_many :message_read_statuses, as: :message

  validates_presence_of :text

  after_create_commit :send_new_chat_notification, unless: :skip_notification
  after_create_commit :create_message_read_statuses, unless: :skip_notification

  private

  def create_message_read_statuses
    Support.find_each do |support|
      message_read_statuses.create(user: support) unless user == support
    end
    message_read_statuses.create(user: payment.merchant) unless user == payment.merchant
    message_read_statuses.create(user: payment.processer) unless user == payment.processer
  end

  def send_new_chat_notification
    return unless payment.arbitration_changed? || payment.arbitration?

    Payments::TelegramNotificationJob.perform_async(payment.id, payment.arbitration_was, text, nil)
  end
end
