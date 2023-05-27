class AddUniqueIndexToCommissions < ActiveRecord::Migration[7.0]
  def change
    add_index :commissions,
              %i[payment_system_id national_currency direction commission_type merchant_id],
              unique: true,
              name: 'index_unique_commission'
  end
end
