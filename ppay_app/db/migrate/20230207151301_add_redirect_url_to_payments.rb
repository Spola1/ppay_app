class AddRedirectUrlToPayments < ActiveRecord::Migration[7.0]
  def change
    add_column :payments, :redirect_url, :string
  end
end
