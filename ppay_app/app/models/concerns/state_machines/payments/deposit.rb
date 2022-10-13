module StateMachines
  module Payments
    module Deposit
      extend ActiveSupport::Concern

      included do
        include AASM

        aasm whiny_transitions: false, column: :payment_status do
          state :draft, initial: true
          state :choosing_payment_system, :waiting_for_processer, :waiting_for_payment, :confirming, :completed, :cancelled

          after_all_transitions :update_status_changed_at

          # show_selection_page
          event :show do
            transitions from: :draft, to: :choosing_payment_system
          end
          
          # search_operator
          event :search do
            before :bind_rate_snapshot
            after  :search_processer

            transitions from: :choosing_payment_system, to: :waiting_for_processer,
                        guard: proc { |params| available_waiting_for_processer?(params) },
                        after: :set_cryptocurrency_amount
          end

          # bind_operator
          event :bind do
            after :create_transactions
            ensure :search_processer

            transitions from: :waiting_for_processer, to: :waiting_for_payment, guard: :has_advertisement?
          end

          # make_deposit
          event :check do
            transitions from: :waiting_for_payment, to: :confirming,
                        guard: proc { |params| valid_image?(params) }
          end

          # show_confirmation
          event :confirm do
            after :complete_transactions

            transitions from: :confirming, to: :completed
          end

          event :cancel do
            transitions from: [:choosing_payment_system, :waiting_for_operator, :waiting_for_payment], to: :cancelled
          end
        end
      end

      private

      def assign_params(params, keys)
        assign_attributes(params.slice(*keys))
        valid?
      end

      def available_waiting_for_processer?(params)
        valid_payment_system?(params) && rate_snapshot.present?
      end

      def valid_payment_system?(params)
        assign_params(params, %i[payment_system])
        validate_payment_system
      end

      def valid_image?(params)
        assign_params(params, %i[image])
        validate_image
      end

      def validate_payment_system
        return true if payment_system.present?

        errors.add(:payment_system, I18n.t('errors.payments.required_payment_system'))
        false
      end

      def validate_image
        return true if image.present?

        errors.add(:image, I18n.t('errors.payments.required_image'))
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

      def search_processer
        ::Payments::SearchProcesserJob.perform_async(id)
      end

      def has_advertisement?
        advertisement.present?
      end

      def update_status_changed_at
        self.status_changed_at = Time.zone.now
      end
    end
  end
end
