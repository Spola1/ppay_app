class MerchantMethod < ApplicationRecord
  belongs_to :merchant
  belongs_to :payment_way
  has_many :commissions, dependent: :destroy

  validates_uniqueness_of :merchant,
                          scope: %i[payment_way direction],
                          message: 'That kind of merchant method already exists.'
end
