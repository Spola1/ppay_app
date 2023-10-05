# frozen_string_literal: true

module Transactions
  class TransactionUnfreezeJob
    include Sidekiq::Job
    sidekiq_options queue: 'default', tags: ['unfreeze_merchant_balance']

    def perform
      transactions_to_unfreeze.each(&:complete!)
    end

    def transactions_to_unfreeze
      Transaction.frozen.freeze_balance_transactions
                 .where('unfreeze_time <= ?', Time.zone.now)
    end
  end
end
