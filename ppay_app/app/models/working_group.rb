# frozen_string_literal: true

class WorkingGroup < User
  has_many :processers
  has_one :balance, as: :balanceable, dependent: :destroy

  after_create :create_balance

  has_many :payments, through: :processers
end
