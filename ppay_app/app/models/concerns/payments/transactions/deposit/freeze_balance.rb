module Payments
  module Transactions
    module Deposit
      module FreezeBalance
        private

        def short_freeze_time = (merchant.short_freeze_days || 0).days.from_now
        def long_freeze_time = (merchant.long_freeze_days || 0).days.from_now

        def short_freeze_amount = main_transaction_amount
        def long_freeze_amount = main_transaction_amount * (merchant.long_freeze_percentage || 0) / 100
        def mixed_short_freeze_amount = short_freeze_amount - long_freeze_amount

        def short_freeze_national_currency_amount = national_currency_transaction_amount

        def long_freeze_national_currency_amount
          national_currency_transaction_amount * (merchant.long_freeze_percentage || 0) / 100
        end

        def mixed_short_freeze_national_currency_amount
          short_freeze_national_currency_amount - long_freeze_national_currency_amount
        end

        def freeze_balance
          case merchant.balance_freeze_type
          when 'short'
            create_freeze_balance_transaction(short_freeze_amount, short_freeze_national_currency_amount,
                                              short_freeze_time)
          when 'long'
            create_freeze_balance_transaction(long_freeze_amount, long_freeze_national_currency_amount,
                                              long_freeze_time)
          when 'mixed'
            create_freeze_balance_transaction(long_freeze_amount, long_freeze_national_currency_amount,
                                              long_freeze_time)
            create_freeze_balance_transaction(mixed_short_freeze_amount, mixed_short_freeze_national_currency_amount,
                                              short_freeze_time)
          end
        end

        def create_freeze_balance_transaction(amount, national_currency_amount, unfreeze_time)
          transactions.create(
            from_balance: merchant.balance,
            to_balance: merchant.balance,
            amount:,
            national_currency_amount:,
            transaction_type: :freeze_balance,
            unfreeze_time:
          )
        end

        def unfreeze_balance
          transactions.frozen.freeze_balance_transactions.each(&:cancel!)
        end
      end
    end
  end
end
