class PaymentWay < ApplicationRecord
  belongs_to :payment_system
  belongs_to :national_currency
end
