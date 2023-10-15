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
        self.status_changed_at = Time.zone.now unless status_changed_at_changed?
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

      def set_payment_system_by_advertisement
        return if payment_system.present?

        self.payment_system = advertisement.payment_system
      end

      def valid_payment_system?(params)
        assign_params(params, %i[payment_system])

        validate_payment_system_availability
      end

      def validate_payment_system_availability
        return true if payment_system.in?(merchant_payment_systems)
        return true if payment_system.blank?

        errors.add(:payment_system, :invalid)
        false
      end

      def merchant_payment_systems
        merchant.payment_systems.where(merchant_methods: { direction: type }).pluck(:name)
      end

      def bind_estimated_rate_snapshot
        rates = rate_snapshots_scope
                .by_national_currency(NationalCurrency.find_by(name: national_currency))
                .by_cryptocurrency(cryptocurrency)

        self.rate_snapshot = rates
                             .where(created_at: 5.minutes.ago..)
                             .order(value: type == 'Deposit' ? :desc : :asc)
                             .first ||
                             rates
                             .order(created_at: :asc)
                             .last
      end

      def bind_rate_snapshot
        return if rate_snapshot

        self.rate_snapshot = rate_snapshots_scope
                             .where(created_at: 2.weeks.ago..)
                             .by_payment_system(PaymentSystem.find_by(name: payment_system))
                             .by_cryptocurrency(cryptocurrency)
                             .order(created_at: :asc)
                             .last
      end

      def rate_snapshots_scope
        type == 'Deposit' ? RateSnapshot.buy : RateSnapshot.sell
      end

      def set_cryptocurrency_amount
        merchant_fee_percentage = merchant.fee_percentage

        self.cryptocurrency_amount = rate_snapshot.to_crypto(national_currency_amount, merchant_fee_percentage)
        self.adjusted_rate = rate_snapshot.adjust_rate(merchant_fee_percentage)
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

      def valid_account_number?(params)
        return true unless merchant.account_number_required?

        assign_params(params, %i[account_number])
        validate_account_number
      end

      def validate_account_number
        return true if account_number.present?

        errors.add(:account_number, :blank)
        false
      end

      def uniqueization_difference
        self.class::UNIQUEIZATION_DIFFERENCE
      end
    end
  end
end
