# frozen_string_literal: true

class AddCommissions < ActiveRecord::Migration[7.0]
  def up
    Merchant.find_each { |merchant| merchant.fill_in_commissions }
  end
end
