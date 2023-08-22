# frozen_string_literal: true

module Payments
  module Dashboard
    class GetStatsInteractor
      include Interactor

      delegate :processer, :filtering_params, :payments, :finished, :completed, :cancelled, :conversion,
               :average_confirmation, :completed_sum, :active_advertisements, :active_advertisements_period,
               :average_arbitration_resolution_time, to: :context

      PERIODS = {
        'last_hour' => 1.hour.ago,
        'last_3_hours' => 3.hours.ago,
        'last_6_hours' => 6.hours.ago,
        'last_12_hours' => 12.hours.ago,
        'last_day' => 1.day.ago,
        'last_3_days' => 3.days.ago,
        'yesterday' => 1.day.ago.beginning_of_day,
        'before_yesterday' => 2.days.ago.beginning_of_day
      }.freeze

      def call
        set_default_params
        set_payments
        set_conversion
        set_average_confirmation
        set_completed_sum
        set_active_advertisements
        set_active_advertisements_period
        set_average_arbitration_resolution_time
      end

      private

      def set_default_params
        if filtering_params.blank? || (filtering_params[:period].blank? && filtering_params[:created_from].blank?)
          context.filtering_params = {} if filtering_params.blank?
          context.filtering_params[:period] = 'last_hour'
        end
      end

      def set_payments
        context.payments = processer.payments.except(:order).filter_by(filtering_params).includes(:merchant)
      end

      def set_conversion
        context.finished = payments.finished.count
        context.completed = payments.completed.count
        context.cancelled = finished - completed
        context.conversion = finished.positive? && completed.positive? ?
          (completed.to_f / finished.to_f * 100).round(2) :
          0
      end

      def set_average_confirmation
        context.average_confirmation = payments
          .completed
          .joins(:audits)
          .where("audited_changes @> '{\"payment_status\": [\"transferring\",\"confirming\"]}'")
          .where.not(id: payments.joins(:audits).where("audited_changes @> '{\"arbitration\": [false, true]}'"))
          .distinct
          .average('payments.status_changed_at - audits.created_at') || 0
      end

      def set_completed_sum
        context.completed_sum = payments.completed.sum(:cryptocurrency_amount).to_f
      end

      def set_active_advertisements
        context.active_advertisements = processer.advertisements.active.group_by(&:national_currency)
      end

      def set_active_advertisements_period
        start_time, end_time = calculate_time_range

        if start_time && end_time
          active_advertisements_period = fetch_active_advertisements_period(start_time, end_time)
          context.active_advertisements_period = active_advertisements_period
        end
      end

      def calculate_time_range_for_period(period)
        if !['yesterday', 'before_yesterday'].include?(period)
          [PERIODS[period], Time.now]
        elsif period == 'yesterday'
          [PERIODS[period], 1.day.ago.end_of_day]
        elsif period == 'before_yesterday'
          [PERIODS[period], 2.days.ago.end_of_day]
        end
      end

      def calculate_time_range_for_created(created_from, created_to)
        [created_from.in_time_zone.beginning_of_day, created_to.in_time_zone.end_of_day]
      end

      def fetch_active_advertisements_period(start_time, end_time)
        context.processer.advertisements.joins(:advertisement_activities)
          .where(
            'advertisement_activities.created_at >= ? AND advertisement_activities.deactivated_at <= ?',
            start_time, end_time
          )
          .distinct
          .group_by(&:national_currency)
      end

      def calculate_time_range
        period = context.filtering_params[:period]
        created_from = context.filtering_params[:created_from]
        created_to = context.filtering_params[:created_to]

        if period.present?
          calculate_time_range_for_period(period)
        else
          calculate_time_range_for_created(created_from, created_to)
        end
      end

      def set_average_arbitration_resolution_time
        start_time, end_time = calculate_time_range

        total_resolution_time = 0
        arbitration_resolutions_count = 0

        context.processer.payments.each do |payment|
          arbitration_resolutions =
            payment.arbitration_resolutions
                   .where(reason: [ArbitrationResolution.reasons[:check_by_check],
                                   ArbitrationResolution.reasons[:incorrect_amount_check]])
                   .completed
                   .where('created_at >= ? AND ended_at IS NOT NULL', start_time)
                   .where('ended_at <= ?', end_time)

          arbitration_resolutions.each do |resolution|
            total_resolution_time += resolution.ended_at - resolution.created_at
            arbitration_resolutions_count += 1
          end
        end

        context.average_arbitration_resolution_time =
          arbitration_resolutions_count.positive? ? total_resolution_time / arbitration_resolutions_count.to_f : 0
      end
    end
  end
end
