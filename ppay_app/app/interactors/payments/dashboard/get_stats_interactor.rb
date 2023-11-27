# frozen_string_literal: true

module Payments
  module Dashboard
    class GetStatsProcesser
      include Interactor

      delegate :processer, :filtering_params, :payments, :finished, :completed, :cancelled, :conversion,
               :average_confirmation, :completed_sum, :active_advertisements, :active_advertisements_period,
               :average_arbitration_resolution_time, :arbitration_resolutions_count,
               to: :context

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
        set_advertisement_conversions
        set_total_average_confirmation
      end

      private

      def set_advertisement_conversions
        start_time, end_time = calculate_time_range

        return unless start_time && end_time

        advertisements = context.processer.advertisements

        advertisements.each do |adv|
          adv.conversion = calculate_conversion_for_advertisements(adv, start_time, end_time)
        end
      end

      def calculate_conversion_for_advertisements(advertisement, start_time, end_time)
        total_completed = advertisement.payments.completed.where(created_at: start_time..end_time).count
        total_finished = advertisement.payments.finished.where(created_at: start_time..end_time).count

        total_finished.positive? ? (total_completed.to_f / total_finished * 100).round(2) : 0
      end

      def set_default_params
        unless filtering_params.blank? || (filtering_params[:period].blank? && filtering_params[:created_from].blank?)
          return
        end

        context.filtering_params = {} if filtering_params.blank?
        context.filtering_params[:period] = 'last_hour'
      end

      def set_payments
        context.payments = processer.payments.except(:order).filter_by(filtering_params).includes(:merchant)
      end

      def set_conversion
        context.finished = payments.without_other_processing.finished.count
        context.completed = payments.without_other_processing.completed.count
        context.cancelled = finished - completed
        context.conversion =
          finished.positive? && completed.positive? ? (completed.to_f / finished * 100).round(2) : 0
      end

      def set_average_confirmation
        context.average_confirmation =
          payments
          .for_average_confirmation
          .average('payments.status_changed_at - audits.created_at') || 0
      end

      def set_total_average_confirmation
        context.total_average_confirmation =
          payments
          .without_other_processing
          .for_average_confirmation
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

        return unless start_time && end_time

        active_advertisements_period = fetch_active_advertisements_period(start_time, end_time)
        context.active_advertisements_period = active_advertisements_period
      end

      def calculate_time_range_for_period(period)
        if !%w[yesterday before_yesterday].include?(period)
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
                 'deactivated_at > :start_time AND advertisement_activities.created_at < :end_time',
                 start_time:, end_time:
               )
               .distinct
               .group_by(&:national_currency)
      end

      def calculate_time_range
        period = context.filtering_params[:period]
        created_from = context.filtering_params[:created_from]
        created_to = context.filtering_params[:created_to].presence || Time.zone.today.to_s

        if period.present?
          calculate_time_range_for_period(period)
        else
          calculate_time_range_for_created(created_from, created_to)
        end
      end

      def set_average_arbitration_resolution_time
        start_time, end_time = calculate_time_range

        arbitration_resolutions =
          ArbitrationResolution
          .completed
          .where(payment: payments,
                 reason: [ArbitrationResolution.reasons[:check_by_check],
                          ArbitrationResolution.reasons[:incorrect_amount_check]].flatten)
          .where('created_at >= ? AND ended_at IS NOT NULL', start_time)
          .where('ended_at <= ?', end_time)

        context.average_arbitration_resolution_time = arbitration_resolutions.average('ended_at - created_at') || 0
        context.arbitration_resolutions_count = arbitration_resolutions.count
      end
    end

    class GetStatsGeneral
      include Interactor

      def call
        set_national_currencies
        set_average_payments_release_time
        set_payments_bandwith
      end

      private

      def set_average_payments_release_time
        context.avg_release_time = {}
        context.national_currencies.each do |currency|
          payments = get_most_frequent_amount_payments(currency)[1]
          context.avg_release_time[currency] =
            if payments
              (payments.map { |payment| (payment.status_changed_at - payment.created_at) / 60 }.sum / payments.count)
                .round(2)
            else
              0
            end
        end
      end

      def set_payments_bandwith
        context.payments_bandwith = {}
        context.national_currencies.each do |currency|
          ad_count = Advertisement.where(national_currency: currency, status: true).count
          avg_release_time = context.avg_release_time[currency]
          context.payments_bandwith[currency] =
            avg_release_time.positive? ? ((1 / avg_release_time) * ad_count).round(2) : 0
        end
      end

      def get_most_frequent_amount_payments(national_currency)
        Payment.where('created_at >= ?', 1.hour.ago)
               .where(payment_status: %w[cancelled completed],
                      national_currency:)
               .group_by(&:national_currency_amount)
               .max_by(&:count) || []
      end

      def set_national_currencies
        context.national_currencies = NationalCurrency.pluck(:name)
      end
    end

    class GetStatsInteractor
      include Interactor::Organizer

      organize GetStatsProcesser, GetStatsGeneral
    end
  end
end
