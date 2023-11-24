# frozen_string_literal: true

module AdvertisementScopes
  extend ActiveSupport::Concern

  included do
    scope :active,               -> { where(status: true) }
    scope :by_amount,            lambda { |amount|
      where('(max_summ >= :amount or max_summ is NULL) AND (min_summ <= :amount or min_summ is NULL)', amount:)
    }
    scope :by_processer_balance, ->(amount) { joins(processer: :balance).where('balances.amount >= ?', amount) }
    scope :by_payment_system,    lambda { |payment_system|
      if payment_system == 'СБП'
        where(national_currency: 'RUB').where.not(sbp_phone_number: '')
      else
        where(payment_system:)
      end
    }
    scope :by_direction,         ->(direction) { where(direction:) }
    scope :order_random,         lambda {
      weights_sum = joins(:processer).unscope(:group).sum('users.sort_weight')
      weights_sum = [weights_sum, 1].max
      order = Arel.sql("(RANDOM() * users.sort_weight / #{weights_sum}) DESC")
      joins(:processer).order(order).group('advertisements.id, users.sort_weight')
    }

    scope :join_active_payments, lambda {
      joins('LEFT OUTER JOIN payments ON (payments.advertisement_id = advertisements.id AND ' \
            "(payments.payment_status IN ('confirming', 'transferring') AND " \
            "NOT (payments.payment_status = 'confirming' AND payments.arbitration = TRUE)))")
    }

    scope :by_whitelisted_processers, lambda { |payment|
      where(processer: payment.merchant.whitelisted_processers) if payment.merchant.only_whitelisted_processers
    }

    scope :for_payment, lambda { |payment|
      join_active_payments
        .by_whitelisted_processers(payment)
        .active
        .by_payment_system(
          payment.payment_system.presence ||
          payment.merchant.payment_systems
            .where(merchant_methods: { direction: payment.type })
            .pluck(:name)
        )
        .group('advertisements.id')
    }

    scope :for_deposit_common, lambda { |payment|
      for_payment(payment)
        .order_by_algorithm(payment.national_currency_amount)
        .by_processer_balance(payment.cryptocurrency_amount)
        .by_amount(payment.national_currency_amount)
        .by_direction('Deposit')
    }

    scope :for_deposit, lambda { |payment|
      for_deposit_common(payment)
        .equal_amount_payments_limited(payment.national_currency_amount, payment.merchant.equal_amount_payments_limit)
    }

    scope :for_deposit_unlimited, lambda { |payment|
      for_deposit_common(payment)
    }

    scope :for_withdrawal, lambda { |payment|
      for_payment(payment)
        .order_by_algorithm(payment.national_currency_amount)
        .by_amount(payment.national_currency_amount)
        .by_direction('Withdrawal')
    }

    scope :order_by_algorithm, lambda { |national_currency_amount|
      order_by_similar_payments(national_currency_amount)
        .order_by_transferring_and_confirming_payments
        .order_by_remaining_confirmation_time
        .order_random
    }

    scope :order_by_transferring_and_confirming_payments, lambda {
      order(Arel.sql('COUNT(payments.id) ASC'))
    }

    scope :order_by_similar_payments, lambda { |national_currency_amount|
      order(Arel.sql("SUM(CASE WHEN payments.national_currency_amount BETWEEN
        #{national_currency_amount * 0.95} AND #{national_currency_amount * 1.05} THEN 1 ELSE 0 END) ASC"))
    }

    scope :order_by_remaining_confirmation_time, lambda {
      order(Arel.sql('SUM(extract(epoch from payments.status_changed_at)) DESC'))
    }

    scope :equal_amount_payments_limited, lambda { |national_currency_amount, limit|
      return unless limit

      having(Arel.sql('SUM(CASE WHEN ' \
                      "payments.national_currency_amount = #{national_currency_amount} " \
                      "THEN 1 ELSE 0 END) < #{limit}"))
    }

    scope :for_enable_status, lambda {
      where(status: false)
        .where(block_reason: :exceed_daily_usdt_limit)
        .joins(:payments)
        .merge(Payment.completed.last_day.except(:order))
        .group('advertisements.id')
        .having('daily_usdt_limit IS NULL OR daily_usdt_limit = 0 ' \
                'OR SUM(payments.cryptocurrency_amount) < daily_usdt_limit')
    }
  end
end
