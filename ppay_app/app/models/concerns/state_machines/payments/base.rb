# frozen_string_literal: true

module StateMachines
  module Payments
    module Base
      extend ActiveSupport::Concern

      private

      def assign_params(params, keys)
        assign_attributes(params.slice(*keys))
        valid?
      end

      def update_status_changed_at
        self.status_changed_at = Time.zone.now
      end

      def search_processer
        "::Payments::SearchProcesser::#{type}Job".constantize.perform_async(id)
      end

      def inline_search_processer
        "::Payments::SearchProcesser::#{type}Job".constantize.new.perform(id)
      end

      def valid_payment_system?(params)
        assign_params(params, %i[payment_system])
        validate_payment_system
      end

      def validate_payment_system
        return true if payment_system.present?

        errors.add(:payment_system, :blank)
        false
      end

      def bind_rate_snapshot
        self.rate_snapshot = RateSnapshot.sell.by_national_currency(national_currency)
                                         .by_cryptocurrency(cryptocurrency)
                                         .order(created_at: :asc)
                                         .last
      end

      def set_cryptocurrency_amount
        self.cryptocurrency_amount = rate_snapshot.to_crypto(national_currency_amount)
      end

      def set_cancellation_reason
        self.cancellation_reason = 0
      end

      def has_advertisement?
        advertisement.present?
      end

      def valid_image?(params)
        assign_params(params, %i[image])
        validate_image
      end

      def validate_image
        return true unless merchant.check_required
        return true if image.present?

        errors.add(:image, :blank)
        false
      end
    end
  end
end
