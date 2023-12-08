class AddSbpBankToPayment < ActiveRecord::Migration[7.0]
  def change
    add_column :payments, :sbp_bank, :string, null: true
  end
end
