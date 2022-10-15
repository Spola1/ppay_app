# frozen_string_literal: true

module Processers
  class ExchangePortalsController < BaseController
    def index
      @exchange_portals = ExchangePortal.all
    end

    def show
      @exchange_portal = ExchangePortal.find(params[:id])
    end

  end
end
