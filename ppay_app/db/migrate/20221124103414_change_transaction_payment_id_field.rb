# frozen_string_literal: true

class ChangeTransactionPaymentIdField < ActiveRecord::Migration[7.0]
  def change
    change_column :transactions, :payment_id, :bigint, null: true
  end
end
