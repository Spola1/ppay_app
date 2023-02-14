# frozen_string_literal: true

module StateMachines
  module Payments
    module Withdrawal
      extend ActiveSupport::Concern
      include Base

      included do
        include AASM

        aasm whiny_transitions: false, column: :payment_status do
          state :created, initial: true
          state :draft, :processer_search, :transferring, :confirming, :completed, :cancelled

          after_all_transitions :update_status_changed_at

          # show_selection_page
          event :show do
            transitions from: :created, to: :draft
          end

          # search_operator
          event :search do
            before :bind_rate_snapshot
            after_commit :search_processer

            transitions from: :draft, to: :processer_search,
                        guard: proc { |params| available_processer_search?(params) },
                        after: :set_cryptocurrency_amount
          end

          # bind_operator
          event :bind do
            after :ensure_unique_amount, :create_transactions
          ensure :search_processer

                 transitions from: :processer_search, to: :transferring, guard: :has_advertisement?
          end

          # inline_bind_operator
          event :inline_bind do
            after :ensure_unique_amount, :create_transactions
          ensure :search_processer

                  transitions from: :processer_search, to: :transferring, guard: :has_advertisement?
          end

          # make_deposit
          event :check do
            transitions from: :transferring, to: :confirming,
                        guard: proc { |params| valid_image?(params) }
          end

          # show_confirmation
          event :confirm do
            after :complete_transactions

            transitions from: :confirming, to: :completed
          end

          event :cancel do
            after :cancel_transactions

            transitions from: %i[draft], to: :cancelled
          end
        end
      end

      private

      def available_processer_search?(params)
        return unless valid_payment_system?(params)
        return unless valid_card_number?(params)
        return unless rate_snapshot.present?

        true
      end

      def valid_card_number?(params)
        assign_params(params, %i[card_number])
        validate_card_number
      end

      def validate_card_number
        return true if card_number && card_number.size == 16

        errors.add(:card_number, :wrong_length, count: 16)
        false
      end

      def ensure_unique_amount
        with_lock do
          recent_payments = self.processer.payments.where.not(payment_status: ['completed', 'cancelled'])
                                                  .where(national_currency: self.national_currency)
          amounts = recent_payments.pluck(:national_currency_amount)

          if !amounts.include?(self.national_currency_amount)
            self.national_currency_amount
          end

          while amounts.include?(self.national_currency_amount) do
            if self.unique_amount_integer?
              self.national_currency_amount += 1
            elsif self.unique_amount_decimal?
              self.national_currency_amount += 0.01
            end

            break if !amounts.include?(self.national_currency_amount)
          end
        end
      end
    end
  end
end
