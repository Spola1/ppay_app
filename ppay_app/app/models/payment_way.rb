class PaymentWay < ApplicationRecord
  belongs_to :payment_system
  belongs_to :national_currency

  validates_uniqueness_of :payment_system_id,
                          scope: %i[national_currency_id],
                          message: 'That kind of payment way already exists.'

end
