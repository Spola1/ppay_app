# frozen_string_literal: true

module StateMachines
  module Payments
    module Deposit
      extend ActiveSupport::Concern
      include Base

      UNIQUEIZATION_DIFFERENCE = { 'integer' => -1, 'decimal' => -0.01 }.freeze

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
            before :ensure_unique_amount, :bind_rate_snapshot, :set_cryptocurrency_amount
            after :create_transactions
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
    end
  end
end
