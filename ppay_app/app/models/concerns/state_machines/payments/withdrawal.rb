# frozen_string_literal: true

module StateMachines
  module Payments
    module Withdrawal
      extend ActiveSupport::Concern
      include Base

      UNIQUEIZATION_DIFFERENCE = { 'integer' => 1, 'decimal' => 0.01 }.freeze

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
            before :bind_estimated_rate_snapshot, :set_cryptocurrency_amount
            after_commit :search_processer

            transitions from: :draft, to: :processer_search,
                        guard: proc { |params| available_processer_search?(params) }
          end

          # search_operator
          event :inline_search do
            before :bind_estimated_rate_snapshot, :set_cryptocurrency_amount
            after_commit :inline_search_processer

            transitions from: :created, to: :processer_search,
                        guard: proc { |params| available_processer_search?(params) }
          end

          # bind_operator
          event :bind do
            before :set_payment_system_by_advertisement, :bind_rate_snapshot, :set_cryptocurrency_amount, :set_locale
            after :create_transactions

            transitions from: :processer_search, to: :transferring, guard: :advertisement?
          end

          # make_deposit
          event :check do
            before :set_locale
            transitions from: :transferring, to: :confirming,
                        guard: proc { |params| valid_image?(params) }
          end

          # show_confirmation
          event :confirm do
            before :set_locale
            after :complete_transactions

            transitions from: %i[transferring confirming], to: :completed,
                        guard: proc { |params| valid_image?(params) }
          end

          event :cancel do
            after :cancel_transactions

            transitions from: %i[draft processer_search transferring confirming], to: :cancelled
          end

          event :restore do
            after :complete_transactions

            transitions from: :cancelled, to: :completed,
                        guard: proc { available_cancelled_transactions? },
                        after: :restore_transactions
          end
        end
      end

      private

      def available_processer_search?(params)
        return unless valid_payment_system?(params)
        return unless valid_card_number?(params)
        return unless insufficient_merchant_balance?
        return unless rate_snapshot.present?

        true
      end

      def valid_card_number?(params)
        assign_params(params, %i[card_number])
        validate_card_number
      end

      def validate_card_number
        return true if card_number && card_number.size >= 4

        errors.add(:card_number, :too_short, count: 4)
        false
      end

      def insufficient_merchant_balance?
        return true if merchant.balance.withdrawable?(full_cryptocurrency_amount, full_national_currency_amount)

        errors.add(:national_currency_amount, :insufficient_balance)
        false
      end

      def valid_image?(params)
        assign_params(params, %i[image])

        return true unless merchant.check_required

        validate_image
      end
    end
  end
end
