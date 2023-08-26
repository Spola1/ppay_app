# frozen_string_literal: true

class Comment < ApplicationRecord
  attr_accessor :skip_notification

  belongs_to :commentable, polymorphic: true
  belongs_to :user, optional: true
  has_many :message_read_statuses, as: :message

  validates_presence_of :text

  after_create_commit :broadcast_payment, if: -> { commentable.type.in?(%w[Deposit Withdrawal]) }
  after_create_commit :send_new_comment_notification, unless: :skip_notification
  after_create_commit :create_message_read_statuses, unless: :skip_notification

  private

  def broadcast_payment
    commentable.broadcast_replace_payment_to_processer
    commentable.broadcast_replace_payment_to_support
  end

  def create_message_read_statuses
    Support.find_each do |support|
      message_read_statuses.create(user: support) unless user == support
    end
    message_read_statuses.create(user: commentable.merchant) unless user == commentable.merchant
    message_read_statuses.create(user: commentable.processer) unless user == commentable.processer
  end

  def send_new_comment_notification
    return unless commentable.arbitration? && commentable.support != user

    Payments::TelegramNotificationJob.perform_async(commentable.id, commentable.arbitration_was, nil, text)
  end
end
