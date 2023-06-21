class AddUniqueIndexToPaymentWays < ActiveRecord::Migration[7.0]
  def change
    add_index :payment_ways,
              %i[payment_system_id national_currency_id],
              unique: true,
              name: 'index_payment_ways_uniqueness'
  end
end
