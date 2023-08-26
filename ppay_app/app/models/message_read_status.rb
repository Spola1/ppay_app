# frozen_string_literal: true

class MessageReadStatus < ApplicationRecord
  belongs_to :user
  belongs_to :message, polymorphic: true
end
