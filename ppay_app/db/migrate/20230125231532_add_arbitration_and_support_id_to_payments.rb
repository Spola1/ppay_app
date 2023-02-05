# frozen_string_literal: true

class AddArbitrationAndSupportIdToPayments < ActiveRecord::Migration[7.0]
  def change
    add_column :payments, :arbitration, :boolean, default: false
    add_reference :payments, :support
  end
end
