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
        transaction.national_currency_amount = payment.national_currency_amount * payment.send(:main_transaction_percent) / 100
        transaction.save!
      end
      
      if transaction.processer_commission? && payment.type == 'Deposit'
        transaction.national_currency_amount = payment.national_currency_amount * payment.send(:processer_commission) / 100
        transaction.save!
      end
      
      if transaction.working_group_commission? && payment.type == 'Deposit'
        transaction.national_currency_amount = payment.national_currency_amount * payment.send(:working_group_commission) / 100
        transaction.save!
      end
      
      if transaction.agent_commission? && payment.type == 'Deposit'
        transaction.national_currency_amount = payment.national_currency_amount * payment.send(:agent_commission) / 100
        transaction.save!
      end
      
      if transaction.ppay_commission? && payment.type == 'Deposit'
        transaction.national_currency_amount = payment.national_currency_amount * payment.send(:ppay_commission) / 100
        transaction.save!
      end
      
      if transaction.main? && payment.type == 'Withdrawal'
        transaction.national_currency_amount = payment.national_currency_amount
        transaction.save!
      end
      
      if transaction.processer_commission? && payment.type == 'Withdrawal'
        transaction.national_currency_amount = payment.national_currency_amount * payment.send(:processer_commission) / 100
        transaction.save!
      end
      
      if transaction.working_group_commission? && payment.type == 'Withdrawal'
        transaction.national_currency_amount = payment.national_currency_amount * payment.send(:working_group_commission) / 100
        transaction.save!
      end
      
      if transaction.agent_commission? && payment.type == 'Withdrawal'
        transaction.national_currency_amount = payment.national_currency_amount * payment.send(:agent_commission) / 100
        transaction.save!
      end
      
      if transaction.ppay_commission? && payment.type == 'Withdrawal'
        transaction.national_currency_amount = payment.national_currency_amount * payment.send(:ppay_commission) / 100
        transaction.save!
      end
    end
  end
end