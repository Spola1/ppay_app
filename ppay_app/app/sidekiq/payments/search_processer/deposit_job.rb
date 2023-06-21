# frozen_string_literal: true

module Payments
  module SearchProcesser
    class DepositJob < Base
      private

      def selected_advertisement(payment)
        advertisements = Advertisement.active
                                   .by_payment_system(payment.payment_system)
                                   .by_processer_balance(payment.cryptocurrency_amount)
                                   .by_direction('Deposit')
                                   .with_arbitration_or_confirming_payment

        if advertisements.blank?
          # Если объявления с условием не найдены,
          # выбрать первое опавшееся объявление подходящее под остальные параметры
          return Advertisement.active
                            .by_payment_system(payment.payment_system)
                            .by_processer_balance(payment.cryptocurrency_amount)
                            .by_direction('Deposit')
                            .sample
        end

        debugger

        result = advertisements
                  .joins(:payments)
                  .where('ABS(payments.national_currency_amount - :amount) > (payments.national_currency_amount * 0.05)', amount: payment.national_currency_amount)
                  .where("payments.payment_status = 'transferring' AND NOT payments.arbitration")
                  .where(national_currency: payment.national_currency)
                  .where(payment_system: payment.payment_system)

        debugger

        if result.blank?
          return Advertisement.active
                            .by_payment_system(payment.payment_system)
                            .by_processer_balance(payment.cryptocurrency_amount)
                            .by_direction('Deposit')
                            .with_arbitration_or_confirming_payment
                            .sample
        end

        #debugger

        if result.present?
          result = result.joins(:payments)
                         .where("ABS(payments.national_currency_amount - :amount) <= (payments.national_currency_amount * 0.05)", amount: payment.national_currency_amount)
                         .where("payments.payment_status = 'transferring' AND NOT payments.arbitration")
                         .where(national_currency: payment.national_currency)
                         .where(payment_system: payment.payment_system)
                         .group("advertisements.id")
                         .order("COUNT(payments.id)")
        end

        debugger
      end
    end
  end
end