# frozen_string_literal: true

module Merchants
  class TransactionsController < BaseController
    def index
      balance_id = current_user.balance.id 
      @transactions = Transaction.where('from_balance_id=? OR to_balance_id=?', balance_id, balance_id)
    end

    def show
      @transaction = Transaction.find(params[:id])
    end
  end
end
