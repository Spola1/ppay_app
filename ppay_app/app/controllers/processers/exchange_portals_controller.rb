# frozen_string_literal: true

module Processers
  class ExchangePortalsController < BaseController
    def index
      @pagy, @exchange_portals = pagy(ExchangePortal.all)
    end

    def show
      @exchange_portal = ExchangePortal.find(params[:id])
    end

  end
end
