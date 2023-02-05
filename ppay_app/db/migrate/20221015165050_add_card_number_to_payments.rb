# frozen_string_literal: true

class AddCardNumberToPayments < ActiveRecord::Migration[7.0]
  def change
    add_column :payments, :card_number, :string
  end
end
