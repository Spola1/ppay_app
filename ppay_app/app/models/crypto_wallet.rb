class CryptoWallet < ApplicationRecord
  belongs_to :user, optional: true

  scope :free, -> { where(user: nil) }

  validates_presence_of :address
end
