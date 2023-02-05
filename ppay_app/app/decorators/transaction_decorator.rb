# frozen_string_literal: true

class TransactionDecorator < ApplicationDecorator
  delegate_all

  def human_status
    Transaction.human_attribute_name("status.#{status}")
  end

  def human_transaction_type
    Transaction.human_attribute_name("transaction_type.#{transaction_type}")
  end
end
