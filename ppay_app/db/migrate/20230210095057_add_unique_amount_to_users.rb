# frozen_string_literal: true

class AddUniqueAmountToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :unique_amount, :integer, default: 0
  end
end
