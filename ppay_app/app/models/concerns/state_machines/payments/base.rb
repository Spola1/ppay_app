# frozen_string_literal: true

module StateMachines
  module Payments
    module Base
      extend ActiveSupport::Concern

      private

      def assign_params(params, keys)
        assign_attributes(params.slice(*keys)) if params
        valid?
      end

      def update_status_changed_at
        self.status_changed_at = Time.zone.now
      end

      def search_processer
        "::Payments::SearchProcesser::#{type}Job".constantize.perform_async(id)
      end

      def inline_search_processer
        "::Payments::SearchProcesser::#{type}Interactor".constantize.call(payment_id: id)

        reload

        advertisement?
      end

      def set_locale
        I18n.locale = locale.to_sym if locale.present?
      rescue I18n::InvalidLocale
        I18n.locale = I18n.default_locale
      end

      def valid_payment_system?(params)
        assign_params(params, %i[payment_system])

        return unless validate_payment_system_presence

        validate_payment_system_availability
      end

      def validate_payment_system_presence
        return true if payment_system.present?

        errors.add(:payment_system, :blank)
        false
      end

      def validate_payment_system_availability
        return true if payment_system.in?(merchant_payment_systems)

        errors.add(:payment_system, :invalid)
        false
      end

      def merchant_payment_systems
        merchant.payment_systems.where(merchant_methods: { direction: type }).pluck(:name)
      end

      def bind_estimated_rate_snapshot
        self.rate_snapshot = rate_snapshots_scope
                             .by_national_currency(NationalCurrency.find_by(name: national_currency))
                             .by_cryptocurrency(cryptocurrency)
                             .where(created_at: 5.minutes.ago..)
                             .order(value: type == 'Deposit' ? :desc : :asc)
                             .first
      end

      def bind_rate_snapshot
        self.rate_snapshot = rate_snapshots_scope
                             .by_payment_system(PaymentSystem.find_by(name: payment_system))
                             .by_cryptocurrency(cryptocurrency)
                             .order(created_at: :asc)
                             .last
      end

      def rate_snapshots_scope
        type == 'Deposit' ? RateSnapshot.buy : RateSnapshot.sell
      end

      def set_cryptocurrency_amount
        self.cryptocurrency_amount = rate_snapshot.to_crypto(national_currency_amount)
      end

      def set_cancellation_reason
        self.cancellation_reason = 0 unless cancellation_reason
      end

      def set_autoconfirming
        self.autoconfirming = advertisement.simbank_auto_confirmation?
      end

      def advertisement?
        return true if advertisement.present?

        errors.add(:advertisement, :not_found)
        false
      end

      def valid_image?(params)
        return true unless merchant.check_required

        assign_params(params, %i[image])
        validate_image
      end

      def validate_image
        return true if image.present?

        errors.add(:image, :blank)
        false
      end

      def uniqueization_difference
        self.class::UNIQUEIZATION_DIFFERENCE
      end
    end
  end
end
