# frozen_string_literal: true

class AddCommissions < ActiveRecord::Migration[7.0]
  def up
    Merchant.all.each do |merchant|
      merchant.commissions.create(
        all_possible_commissions
      )
    end
  end

  def all_possible_commissions
    payment_systems = PaymentSystem.all.map { {payment_system: _1} }
    national_currencies = Settings.national_currencies.map { {national_currency: _1} }
    directions = %w[Deposit Withdrawal].map { {direction: _1} }
    commission_types = %i[ppay processer working_group agent].map { {commission_type: _1} }

    [{commission: 1}]
      .product(payment_systems, national_currencies, directions, commission_types)
      .map { _1.inject(:merge) }
  end
end
