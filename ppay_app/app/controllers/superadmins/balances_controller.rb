# frozen_string_literal: true

module Superadmins
  class BalancesController < Staff::BaseController
    def index
      @pagy, @balances = pagy(Balance.all)
    end
  end
end
