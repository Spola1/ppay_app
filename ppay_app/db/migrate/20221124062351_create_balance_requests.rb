# frozen_string_literal: true

class CreateBalanceRequests < ActiveRecord::Migration[7.0]
  def change
    create_table :balance_requests do |t|
      t.timestamps
      t.integer  :user_id
      t.integer  :requests_type, default: 0, null: false
      t.decimal  :amount, precision: 12, scale: 2
      t.integer  :status, default: 0, null: false
      t.string   :crypto_address
    end
  end
end
