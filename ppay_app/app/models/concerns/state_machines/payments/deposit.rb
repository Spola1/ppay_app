# frozen_string_literal: true

module StateMachines
  module Payments
    module Deposit
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
            after :create_transactions, :ensure_unique_amount
          ensure :search_processer

            transitions from: :processer_search, to: :transferring, guard: :has_advertisement?
          end

          # inline_bind_operator
          event :inline_bind do
            after :create_transactions, :ensure_unique_amount
          ensure :inline_search_processer

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
            before :set_cancellation_reason
            after :cancel_transactions

            transitions from: %i[draft processer_search transferring], to: :cancelled
          end
        end
      end

      private

      def available_processer_search?(params)
        valid_payment_system?(params) && rate_snapshot.present?
      end

      def ensure_unique_amount
        with_lock do
          recent_payments = processer.payments.where.not(payment_status: ['completed', 'cancelled'])
                                                  .where(national_currency: national_currency)
          amounts = recent_payments.pluck(:national_currency_amount)

          while amounts.include?(national_currency_amount) do
            if unique_amount_integer?
              self.national_currency_amount += 1
            elsif unique_amount_decimal?
              self.national_currency_amount += 0.01
            else
              self.national_currency_amount
            end
          end
        end
      end
    end
  end
end
