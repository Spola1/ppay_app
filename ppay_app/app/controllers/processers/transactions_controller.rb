# frozen_string_literal: true

module Processers
  class TransactionsController < BaseController
    def index
      @transactions = Transaction.all
    end

    def show
      @transaction = Transaction.find(params[:id])
    end
  end
end