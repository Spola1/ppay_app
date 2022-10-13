# frozen_string_literal: true

class ExchangePortalsController < ApplicationController
  before_action :authenticate_user!

  def index
    @exchange_portals = ExchangePortal.all
  end

  def show
    @exchange_portal = ExchangePortal.find(params[:id])
  end

end
