# frozen_string_literal: true

module Merchants
  class TransactionsController < ApplicationController
    def index
      @pagy, @freeze_transactions =
        pagy(Transaction.where(transaction_type: :freeze_balance,
                               status: 'frozen',
                               from_balance: current_user.balance))
    end
  end
end
