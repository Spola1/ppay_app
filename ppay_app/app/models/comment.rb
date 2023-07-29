# frozen_string_literal: true

class Comment < ApplicationRecord
  belongs_to :commentable, polymorphic: true
  belongs_to :user, optional: true

  validates_presence_of :text

  after_create_commit :broadcast_payment, if: -> { commentable.type.in?(%w[Deposit Withdrawal]) }

  private

  def broadcast_payment
    commentable.broadcast_replace_payment_to_processer
    commentable.broadcast_replace_payment_to_support
  end
end
