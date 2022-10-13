# frozen_string_literal: true

class Transaction < ApplicationRecord
  include AASM

  belongs_to :from_balance, class_name: 'Balance'
  belongs_to :to_balance, class_name: 'Balance'
  belongs_to :payment

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
    from_balance.withdraw(amount)
  end

  def unfreeze_funds
    from_balance.deposit(amount)
  end

  def deposit_funds
    to_balance.deposit(amount)
  end
end
