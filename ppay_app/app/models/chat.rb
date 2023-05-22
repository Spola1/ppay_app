# frozen_string_literal: true

class Chat < ApplicationRecord
  belongs_to :payment
  belongs_to :user, optional: true

  validates_presence_of :text
end
