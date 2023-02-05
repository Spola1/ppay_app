# frozen_string_literal: true

module Processers
  class TransactionsController < Staff::BaseController
    def index
      @pagy, @transactions = pagy(current_user.balance.transactions.order(created_at: :desc))
    end

    def show
      @transaction = current_user.balance.transactions.find(params[:id])
    end
  end
end
