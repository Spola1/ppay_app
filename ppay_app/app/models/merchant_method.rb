class MerchantMethod < ApplicationRecord
  belongs_to :merchant
  belongs_to :payment_way
end
