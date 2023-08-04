# frozen_string_literal: true

module Payments
  module Dashboard
    class GetStatsInteractor
      include Interactor

      delegate :processer, :filtering_params, :payments, :finished, :completed, :cancelled, :conversion,
               :average_confirmation, :completed_sum, :active_advertisements, to: :context

      def call
        set_payments
        set_conversion
        set_average_confirmation
        set_completed_sum
        set_active_advertisements
      end

      private

      def set_payments
        context.payments = processer.payments.except(:order).filter_by(filtering_params).includes(:merchant)
      end

      def set_conversion
        context.finished = payments.finished.count
        context.completed = payments.completed.count
        context.cancelled = finished - completed
        context.conversion = finished.positive? && completed.positive? ?
          completed.to_f / finished.to_f * 100 :
          0
      end

      def set_average_confirmation
        context.average_confirmation = payments
          .completed
          .joins(:audits)
          .where("audits.audited_changes @> '{\"payment_status\": [\"transferring\",\"confirming\"]}'")
          .average('payments.status_changed_at - audits.created_at') || 0
      end

      def set_completed_sum
        context.completed_sum = payments.completed.sum(:cryptocurrency_amount).to_f
      end

      def set_active_advertisements
        context.active_advertisements = processer.advertisements.active.group_by(&:national_currency)
      end
    end
  end
end
