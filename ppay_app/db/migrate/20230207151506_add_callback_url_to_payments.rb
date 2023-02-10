class AddCallbackUrlToPayments < ActiveRecord::Migration[7.0]
  def change
    add_column :payments, :callback_url, :string
  end
end
