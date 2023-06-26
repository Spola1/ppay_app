class AddUniqueIndexToPaymentSystems < ActiveRecord::Migration[7.0]
  def change
    add_index :payment_systems,
              %i[name national_currency_id],
              unique: true,
              name: 'index_payment_systems_uniqueness'
  end
end
