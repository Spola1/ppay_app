# frozen_string_literal: true

module AdvertisementScopes
  extend ActiveSupport::Concern

  included do
    scope :active,               -> { where(status: true) }
    scope :by_payment_system,    ->(payment_system) { where(payment_system:) }
    scope :by_amount,            ->(amount) { where('max_summ >= :amount AND min_summ <= :amount', amount:) }
    scope :by_processer_balance, ->(amount) { joins(processer: :balance).where('balances.amount >= ?', amount) }
    scope :by_direction,         ->(direction) { where(direction:) }

    scope :order_by_arbitration_and_confirming_payments, -> do
      order_sql = <<-SQL.squish
        SUM(
          CASE WHEN payments.arbitration = TRUE OR payments.payment_status = 'confirming' THEN 1 ELSE 0 END
        ) ASC
      SQL

      arel = Arel.sql(order_sql)

      left_joins(:payments)
        .group('advertisements.id')
        .order(arel)
    end

    scope :order_by_similar_payments, -> (national_currency_amount) do
      order_sql = <<-SQL.squish
        SUM(
          CASE WHEN payments.national_currency_amount BETWEEN #{national_currency_amount * 0.95}
            AND #{national_currency_amount * 1.05} AND payments.payment_status NOT IN ('completed', 'cancelled')
            THEN 1 ELSE 0 END
        ) ASC
      SQL

      arel = Arel.sql(order_sql)

      left_joins(:payments)
        .group('advertisements.id')
        .order(arel)
    end

    scope :order_by_similar_payments_count, -> (national_currency_amount) do
      order_sql = <<-SQL.squish
        SUM(
          CASE WHEN ABS(payments.national_currency_amount - #{national_currency_amount}) / #{national_currency_amount} <= 0.05
            THEN 1 ELSE 0 END
        ) ASC
      SQL

      arel = Arel.sql(order_sql)

      left_joins(:payments)
        .group('advertisements.id')
        .order(arel)
    end

    scope :for_deposit, -> (payment) do
      active
        .by_payment_system(payment.payment_system)
        .by_processer_balance(payment.cryptocurrency_amount)
        .by_direction('Deposit')
    end

    scope :for_withdrawal, -> (payment) do
      active
        .by_payment_system(payment.payment_system)
        .by_processer_balance(payment.cryptocurrency_amount)
        .by_direction('Withdrawal')
    end
  end
end
