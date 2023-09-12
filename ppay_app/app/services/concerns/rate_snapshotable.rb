# frozen_string_literal: true

module RateSnapshotable
  extend ActiveSupport::Concern

  included do
    attr_reader :payment_system, :params
  end

  private

  def in_progress_lock
    payment_system.with_lock do
      return if payment_system.in_progress

      payment_system.update(in_progress: true)
    end

    return if too_recent_rate_snapshot?

    yield
  ensure
    payment_system.update(in_progress: false)
  end

  def recent_snapshot
    @recent_snapshot ||=
      ::RateSnapshot.where(direction: params[:action])
                    .by_payment_system(payment_system)
                    .order(created_at: :desc)
                    .first
  end

  def too_recent_rate_snapshot?
    recent_snapshot ? (Time.zone.now - recent_snapshot.created_at) < 55.seconds : false
  end

  def rate_factor
    1 + (extra_percent / 100)
  end

  def extra_percent
    params[:action] == 'buy' ? payment_system.extra_percent_deposit : payment_system.extra_percent_withdrawal
  end
end
