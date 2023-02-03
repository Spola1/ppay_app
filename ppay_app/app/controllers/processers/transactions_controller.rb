# frozen_string_literal: true

module Processers
  class TransactionsController < Staff::BaseController
    def index
      @pagy, @transactions = pagy(current_user.transactions.order(created_at: :desc))
    end

    def show
      @transaction = current_user.transactions.find(params[:id])
    end
  end
end