# frozen_string_literal: true

module StateMachines
  module Payments
    module Deposit
      extend ActiveSupport::Concern
      include Base

      UNIQUEIZATION_DIFFERENCE = { 'integer' => -1, 'decimal' => -0.01 }.freeze

      included do
        include AASM

        aasm whiny_transitions: false, column: :payment_status, requires_lock: true do
          state :created, initial: true
          state :draft, :processer_search, :transferring, :confirming, :completed, :cancelled

          after_all_transitions :update_status_changed_at

          # show_selection_page
          event :show do
            before :bind_rate_snapshot
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

          # search_operator
          event :inline_search do
            before :bind_rate_snapshot
            after_commit :inline_search_processer

            transitions from: :created, to: :processer_search,
                        guard: proc { |params| available_processer_search?(params) },
                        after: :set_cryptocurrency_amount
          end

          # bind_operator
          event :bind do
            before :ensure_unique_amount, :bind_rate_snapshot, :set_cryptocurrency_amount, :set_locale
            after :create_transactions
            ensure :search_processer # rubocop:disable Layout/RescueEnsureAlignment

            transitions from: :processer_search, to: :transferring, guard: :advertisement? # rubocop:disable Layout/IndentationConsistency
          end

          # make_deposit
          event :check do
            transitions from: :transferring, to: :confirming,
                        guard: proc { |params| valid_image?(params) }
          end

          # show_confirmation
          event :confirm do
            before :set_locale
            after :complete_transactions

            transitions from: %i[transferring confirming], to: :completed
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
        return if unique_amount_none?

        recent_payments = advertisement.deposits.active.excluding(self)
        amounts = recent_payments.pluck(:national_currency_amount)

        while amounts.include?(national_currency_amount)
          self.national_currency_amount += uniqueization_difference[unique_amount]
        end
      end
    end
  end
end
