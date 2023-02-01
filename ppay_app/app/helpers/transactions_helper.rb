# frozen_string_literal: true

module TransactionsHelper
  def transaction_color(transaction, balance)
    return if transaction.cancelled?

    transaction.from_balance == balance ? 'text-red-500' : 'text-green-500'
  end

  def transaction_icon(transaction, balance)
    transaction.from_balance == balance ? 'arrow-down' : 'arrow-up'
  end
end
