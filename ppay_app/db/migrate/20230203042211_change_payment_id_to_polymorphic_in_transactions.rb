# frozen_string_literal: true

class ChangePaymentIdToPolymorphicInTransactions < ActiveRecord::Migration[7.0]
  def change
    add_reference :transactions, :transactionable, polymorphic: true

    reversible do |dir|
      dir.up { Transaction.update_all("transactionable_id = payment_id, transactionable_type='Payment'") }
      dir.down { Transaction.update_all('payment_id = transactionable_id') }
    end

    remove_reference :transactions, :payment, index: true, foreign_key: true
  end
end
