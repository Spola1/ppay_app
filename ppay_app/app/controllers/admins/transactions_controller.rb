# frozen_string_literal: true

module Admins
  class TransactionsController < BaseController
    def index
      @pagy, @transactions = pagy(Transaction.all)
    end

    def show
      @transaction = Transaction.find(params[:id])
    end
  end
end