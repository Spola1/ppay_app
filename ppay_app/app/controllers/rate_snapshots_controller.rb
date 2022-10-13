# frozen_string_literal: true

class RateSnapshotsController < ApplicationController
  before_action :authenticate_user!

  def index
    @rate_snapshots = RateSnapshot.all
  end

  def show
    @rate_snapshot = RateSnapshot.find(params[:id])
    @rate_portal_name = ExchangePortal.find(@rate_snapshot.exchange_portal_id).name
  end

end
