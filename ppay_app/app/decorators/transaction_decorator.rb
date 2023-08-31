# frozen_string_literal: true

class TransactionDecorator < ApplicationDecorator
  delegate_all

  def human_status
    Transaction.human_attribute_name("status.#{status}")
  end

  def human_transaction_type
    Transaction.human_attribute_name("transaction_type.#{transaction_type}")
  end

  def national_formatted
    formatted_amount(national_currency_amount)
  end

  def amount_formatted
    formatted_amount(amount)
  end

  def crypto_currency
    transactionable.cryptocurrency
  end

  def national_currency
    transactionable.national_currency
  end
end
