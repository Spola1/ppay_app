# frozen_string_literal: true

class UpdateCompletedPayments < ActiveRecord::Migration[7.0]
  def up
    Payment.where(payment_status: 'completed').each do |payment|
      calculate_national_currency_amount(payment)
    end
  end

  def down
  end

  private

  def calculate_national_currency_amount(payment)
    payment.transactions.each do |transaction|
      transaction.national_currency_amount = transaction.amount
      transaction.save!
    end
  end
end
