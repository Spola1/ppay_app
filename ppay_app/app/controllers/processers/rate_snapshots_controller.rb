# frozen_string_literal: true

module Processers
  class RateSnapshotsController < BaseController
    def index
      @rate_snapshots = RateSnapshot.all
    end

    def show
      @rate_snapshot = RateSnapshot.find(params[:id])
      @rate_portal_name = ExchangePortal.find(@rate_snapshot.exchange_portal_id).name
    end
  end
end
