class AddUniqueIndexToMerchantMethods < ActiveRecord::Migration[7.0]
  def change
    add_index :merchant_methods,
              %i[merchant_id payment_system_id direction],
              unique: true,
              name: 'index_merchant_methods_uniqueness'
  end
end
