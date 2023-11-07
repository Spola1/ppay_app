# frozen_string_literal: true

class AddSbpToNationalCurrencies < ActiveRecord::Migration[7.0]
  class PaymentSystem < ApplicationRecord
    belongs_to :national_currency
  end

  class NationalCurrency < ApplicationRecord; end

  def up
    ApplicationRecord.connection.schema_cache.clear!
    ApplicationRecord.reset_column_information

    sbp_payment_system = { national_currency: 'RUB', payment_system: 'СБП' }

    ps = PaymentSystem.find_or_create_by(name: sbp_payment_system[:payment_system])
    nc = NationalCurrency.find_or_create_by(name: sbp_payment_system[:national_currency])

    ps.update(national_currency: nc)
  end
end