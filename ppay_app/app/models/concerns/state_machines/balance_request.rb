# frozen_string_literal: true

module StateMachines
  module BalanceRequest
    extend ActiveSupport::Concern

    included do
      include AASM

      aasm whiny_transitions: false, column: :status do
        state :processing, initial: true
        state :completed, :cancelled

        event :complete do
          after { balance_transaction.complete! }

          transitions from: :processing, to: :completed
        end

        event :cancel do
          after { balance_transaction.cancel! }

          transitions from: :processing, to: :cancelled
        end
      end
    end
  end
end
