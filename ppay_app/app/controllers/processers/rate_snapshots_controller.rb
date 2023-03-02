# frozen_string_literal: true

module Processers
  class RateSnapshotsController < Staff::BaseController
    def index
      @pagy, @rate_snapshots = pagy(RateSnapshot.all.order(created_at: :desc))
    end

    def show
      @rate_snapshot = RateSnapshot.find(params[:id])
      @rate_portal_name = ExchangePortal.find(@rate_snapshot.exchange_portal_id).name
    end
  end
end
