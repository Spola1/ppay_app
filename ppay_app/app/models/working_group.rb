class WorkingGroup < ApplicationRecord
  has_many :processers
  has_one :balance, as: :balanceable, dependent: :destroy

  after_create :create_balance
end
