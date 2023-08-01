class AddAutoconfirmingToPayments < ActiveRecord::Migration[7.0]
  def change
    add_column :payments, :autoconfirming, :boolean, default: false
  end
end
