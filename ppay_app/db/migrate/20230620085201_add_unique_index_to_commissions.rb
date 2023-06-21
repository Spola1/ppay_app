class AddUniqueIndexToCommissions < ActiveRecord::Migration[7.0]
  def change
    add_index :commissions,
              %i[commission_type merchant_method_id],
              unique: true,
              name: 'index_commissions_uniqueness'
  end
end
