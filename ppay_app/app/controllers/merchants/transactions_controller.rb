# frozen_string_literal: true

module Merchants
  class TransactionsController < BaseController
    def index
      @pagy, @transactions = pagy(current_user.balance.transactions)
      @transactions = @transactions.decorate
    end

    def show
      @transaction = current_user.transactions.find(params[:id]).decorate
    end
  end
end
