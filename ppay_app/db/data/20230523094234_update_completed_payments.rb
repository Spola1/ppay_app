# frozen_string_literal: true

class UpdateCompletedPayments < ActiveRecord::Migration[7.0]
  
  def up
    Payment.all.each do |payment|
      calculate_national_currency_amount(payment)
    end
  end

  def down
    Transaction.update_all(national_currency_amount: nil)
  end

  private

  def calculate_national_currency_amount(payment)
    payment.transactions.each do |transaction|
      if transaction.main? && payment.type == 'Deposit'
        transaction.national_currency_amount = payment.national_currency_amount * main_transaction_percent(payment) / 100
        transaction.save!
      end
      
      if transaction.processer_commission? && payment.type == 'Deposit'
        transaction.national_currency_amount = payment.national_currency_amount * processer_commission(payment) / 100
        transaction.save!
      end
      
      if transaction.working_group_commission? && payment.type == 'Deposit'
        transaction.national_currency_amount = payment.national_currency_amount * working_group_commission(payment) / 100
        transaction.save!
      end
      
      if transaction.agent_commission? && payment.type == 'Deposit'
        transaction.national_currency_amount = payment.national_currency_amount * agent_commission(payment) / 100
        transaction.save!
      end
      
      if transaction.ppay_commission? && payment.type == 'Deposit'
        transaction.national_currency_amount = payment.national_currency_amount * ppay_commission(payment) / 100
        transaction.save!
      end
      
      if transaction.main? && payment.type == 'Withdrawal'
        transaction.national_currency_amount = payment.national_currency_amount
        transaction.save!
      end
      
      if transaction.processer_commission? && payment.type == 'Withdrawal'
        transaction.national_currency_amount = payment.national_currency_amount * processer_commission(payment) / 100
        transaction.save!
      end
      
      if transaction.working_group_commission? && payment.type == 'Withdrawal'
        transaction.national_currency_amount = payment.national_currency_amount * working_group_commission(payment) / 100
        transaction.save!
      end
      
      if transaction.agent_commission? && payment.type == 'Withdrawal'
        transaction.national_currency_amount = payment.national_currency_amount * agent_commission(payment) / 100
        transaction.save!
      end
      
      if transaction.ppay_commission? && payment.type == 'Withdrawal'
        transaction.national_currency_amount = payment.national_currency_amount * ppay_commission(payment) / 100
        transaction.save!
      end
    end
  end

  def merchant_commissions(payment)
    payment.merchant.commissions
      .where(
        direction: payment.type,
        payment_system: PaymentSystem.find_by(name: payment.payment_system),
        national_currency: payment.national_currency
      )
  end

  def processer_commission(payment)
    merchant_commissions(payment).processer.first&.commission || 1
  end

  def working_group_commission(payment)
    merchant_commissions(payment).working_group.first&.commission || 1
  end

  def agent_commission(payment)
    merchant_commissions(payment).agent.first&.commission || 1
  end

  def ppay_commission(payment)
    merchant_commissions(payment).ppay.first&.commission || 1
  end

  def main_transaction_percent(payment)
    100 - processer_commission(payment) - working_group_commission(payment) - agent_commission(payment) - ppay_commission(payment)
  end
end
