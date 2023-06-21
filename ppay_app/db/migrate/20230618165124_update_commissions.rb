class UpdateCommissions < ActiveRecord::Migration[7.0]
  def up
    add_reference :commissions, :merchant_method, null: true, foreign_key: true

    payment_ways = PaymentWay.all.map { { [_1.payment_system.id, _1.national_currency.id] => _1.id } }.inject(:merge)

    Commission.all.each do |commission|
      commission_payment_way = [
        commission.payment_system_id,
        NationalCurrency.find_by!(name: commission.national_currency).id
      ]

      if payment_ways.include?(commission_payment_way)
        commission.merchant_method = MerchantMethod.find_or_create_by!(
          {
            merchant: commission.merchant,
            payment_way: PaymentWay.find_by_id(payment_ways[commission_payment_way]),
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
