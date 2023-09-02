# frozen_string_literal: true

module Transactions
  class TransactionUnfreezeJob
    include Sidekiq::Job
    sidekiq_options queue: 'default', tags: ['unfreeze_merchant_balance']

    def perform
      transactions_to_unfreeze = Transaction.where(status: :frozen, transaction_type: :freeze_balance)
                                            .where('unfreeze_time <= ?', Time.now)

      transactions_to_unfreeze.each(&:complete!)
    end
  end
end
