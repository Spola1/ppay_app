# frozen_string_literal: true

class BalanceRequest < ApplicationRecord
  include StateMachines::BalanceRequest
  include Filterable

  has_one :balance_transaction, as: :transactionable, class_name: 'Transaction'

  belongs_to :user

  enum requests_type: {
    deposit: 0,
    withdraw: 1
  }

  enum status: {
    processing: 0,
    completed: 1,
    cancelled: 2
  }

  before_validation :set_crypto_address, on: :create, if: -> { deposit? }
  after_create :create_transaction
  after_create_commit :send_new_balance_request_notification

  validates_presence_of :crypto_address
  validates_numericality_of :amount, greater_than: 0

  scope :filter_by_status, ->(status) { where(status:) }

  private

  def send_new_balance_request_notification
    BalanceRequests::Admins::NewBalanceRequestNotificationJob.perform_async(id)
  end

  def create_transaction
    send("create_#{requests_type}_transaction")
  end

  def create_deposit_transaction
    create_balance_transaction(to_balance: user.balance,
                               amount:,
                               transaction_type: :deposit,
                               national_currency_amount: amount)
  end

  def create_withdraw_transaction
    create_balance_transaction(from_balance: user.balance,
                               amount:,
                               transaction_type: :withdraw,
                               national_currency_amount: amount)
  end

  def set_crypto_address
    self.crypto_address = user&.crypto_wallet&.address
  end
end
