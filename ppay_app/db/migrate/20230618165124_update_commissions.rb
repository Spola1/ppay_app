class UpdateCommissions < ActiveRecord::Migration[7.0]

  class Commission < ApplicationRecord
    belongs_to :payment_system
    belongs_to :merchant
    belongs_to :merchant_method
  end

  def up
    add_reference :commissions, :merchant_method, null: true, foreign_key: true

    payment_systems = PaymentSystem.all.map { { [_1.name, _1.national_currency.id] => _1.id } }.inject(:merge)

    Commission.all.each do |commission|
      commission_payment_system = [
        commission.payment_system.name,
        NationalCurrency.find_by!(name: commission.national_currency).id
      ]

      if payment_systems.include?(commission_payment_system)
        commission.merchant_method = MerchantMethod.find_or_create_by!(
          {
            merchant: commission.merchant,
            payment_system: PaymentSystem.find_by_id(payment_systems[commission_payment_system]),
            direction: commission.direction,
          }
        )

        commission.save
      else
        commission.destroy
      end
    end

    change_column_null :commissions, :merchant_method_id, false

    remove_reference :commissions, :merchant
    remove_reference :commissions, :payment_system, foreign_key: true
    remove_column    :commissions, :national_currency
    remove_column    :commissions, :direction
  end
end
