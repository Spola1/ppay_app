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

          # show_selection_page
          event :show do
            transitions from: :created, to: :draft
          end

          # search_operator
          event :search do
            before :bind_estimated_rate_snapshot
            after_commit :search_processer

            transitions from: :draft, to: :processer_search,
                        guard: proc { |params| available_processer_search?(params) },
                        after: :set_cryptocurrency_amount
          end

          # search_operator
          event :inline_search do
            before :bind_estimated_rate_snapshot
            after_commit :inline_search_processer

            transitions from: :created, to: :processer_search,
                        guard: proc { |params| available_processer_search?(params) },
                        after: :set_cryptocurrency_amount
          end

          # bind_operator
          event :bind do
            before :set_payment_system_by_advertisement, :ensure_unique_amount, :bind_rate_snapshot,
                   :set_cryptocurrency_amount, :set_locale, :set_autoconfirming
            after :create_transactions
            ensure :search_processer # rubocop:disable Layout/RescueEnsureAlignment

            transitions from: :processer_search, to: :transferring, guard: :advertisement? # rubocop:disable Layout/IndentationConsistency
          end

          # make_deposit
          event :check do
            after_commit :add_simbank_comment

            transitions from: :transferring, to: :confirming,
                        guard: proc { |params| valid_image?(params) && valid_account_number?(params) }
          end

          # recreate transactions with new amounts
          event :recalculate do
            before :set_cryptocurrency_amount
            after do
              cancel_transactions unless cancelled?
              destroy_transactions
              create_transactions
              cancel_transactions if cancelled?
            end

            transitions from: :transferring, to: :transferring, guard: proc { available_frozen_transactions? }
            transitions from: :confirming, to: :confirming, guard: proc { available_frozen_transactions? }
            transitions from: :cancelled, to: :cancelled, guard: proc { available_cancelled_transactions? }
          end

          # show_confirmation
          event :confirm do
            before :set_locale
            after :complete_transactions, :freeze_balance

            transitions from: %i[transferring confirming], to: :completed
          end

          event :cancel do
            before :set_cancellation_reason
            after :cancel_transactions

            transitions from: %i[draft processer_search transferring confirming], to: :cancelled
          end

          event :restore do
            transitions from: :cancelled, to: :completed, guard: proc { available_cancelled_transactions? },
                        after: %i[restore_transactions complete_transactions freeze_balance]
          end

          event :rollback do
            after :unfreeze_balance, :rollback_transactions

            transitions from: :completed, to: :cancelled, guard: proc { transactions_rollbackable? }
          end
        end
      end

      private

      def available_processer_search?(params)
        return unless valid_payment_system?(params)
        return unless rate_snapshot.present?

        true
      end

      def ensure_unique_amount
        return if unique_amount_none?

        recent_payments = advertisement.deposits.active.excluding(self)
        amounts = recent_payments.pluck(:national_currency_amount)

        while amounts.include?(national_currency_amount)
          self.national_currency_amount += uniqueization_difference[unique_amount]
        end
      end

      def add_simbank_comment
        return unless autoconfirming

        comments.create(
          author_nickname: Settings.simbank_nickname,
          user_id: processer.id,
          text: 'Проверка по симбанку. Ждем 3 минуты',
          skip_notification: true
        )
      end
    end
  end
end
