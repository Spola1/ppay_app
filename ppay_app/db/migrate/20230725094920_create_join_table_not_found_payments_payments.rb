class CreateJoinTableNotFoundPaymentsPayments < ActiveRecord::Migration[7.0]
  def change
    create_join_table :not_found_payments, :payments, table_name: :not_found_payments_payments do |t|
      t.index [:not_found_payment_id, :payment_id], name: 'index_nfp_payments_on_nfp_id_and_p_id'
      t.index [:payment_id, :not_found_payment_id], name: 'index_nfp_payments_on_p_id_and_nfp_id'
    end
  end
end