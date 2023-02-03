# frozen_string_literal: true

module Merchants
  class TransactionsController < Staff::BaseController
    def index
      @pagy, @transactions = pagy(current_user.balance.transactions.order(created_at: :desc))
      @transactions = @transactions.decorate
    end

    def show
      @transaction = current_user.balance.transactions.find(params[:id]).decorate
    end
  end
end
