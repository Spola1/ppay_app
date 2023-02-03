# frozen_string_literal: true

class Transaction < ApplicationRecord
  include AASM
  include DateFilterable

  belongs_to :from_balance, class_name: 'Balance', optional: true
  belongs_to :to_balance, class_name: 'Balance', optional: true
  belongs_to :transactionable, polymorphic: true, optional: true

  enum transaction_type: {
    main: 0,
    ppay_commission: 1,
    processer_commission: 2,
    agent_commission: 3,
    working_group_commission: 4,
    deposit: 5,
    withdraw: 6,
  }

  aasm whiny_transitions: false, column: :status do
    state :frozen, initial: true, before_enter: :freeze_funds
    state :completed, :cancelled

    event :complete do
      transitions from: :frozen, to: :completed, after: :deposit_funds
    end

    event :cancel do
      transitions from: :frozen, to: :cancelled, after: :unfreeze_funds
    end
  end

  private

  def freeze_funds
    from_balance&.withdraw(amount)
  end

  def unfreeze_funds
    from_balance&.deposit(amount)
  end

  def deposit_funds
    to_balance&.deposit(amount)
  end
end
