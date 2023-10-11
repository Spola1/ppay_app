# frozen_string_literal: true

module Processers
  class RateSnapshotsController < Staff::BaseController
    def index
      @pagy, @rate_snapshots = pagy(
        RateSnapshot.includes(payment_system: :national_currency)
                    .order(created_at: :desc).where.not(payment_system: nil)
      )
    end

    def show
      @rate_snapshot = RateSnapshot.find(params[:id])
      @rate_portal_name = ExchangePortal.find(@rate_snapshot.exchange_portal_id).name
    end
  end
end
