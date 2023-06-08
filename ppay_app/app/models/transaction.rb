# frozen_string_literal: true

class Transaction < ApplicationRecord
  include AASM
  include DateFilterable

  PAYMENT_TYPES = %i[main ppay_commission processer_commission agent_commission working_group_commission].freeze
  BALANCE_TYPES = %i[deposit withdraw].freeze
  COMMISSION_TYPES = %i[ppay_commission processer_commission agent_commission working_group_commission].freeze

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
    withdraw: 6
  }

  scope :payment_transactions, ->    { where(transaction_type: PAYMENT_TYPES) }
  scope :commission_transactions, -> { where(transaction_type: COMMISSION_TYPES) }
  scope :balance_transactions, ->    { where(transaction_type: BALANCE_TYPES) }

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
    from_balance&.withdraw(amount, national_currency_amount)
  end

  def unfreeze_funds
    from_balance&.deposit(amount, national_currency_amount)
  end

  def deposit_funds
    to_balance&.deposit(amount, national_currency_amount)
  end
end
