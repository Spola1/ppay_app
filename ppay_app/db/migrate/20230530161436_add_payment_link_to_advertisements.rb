class AddPaymentLinkToAdvertisements < ActiveRecord::Migration[7.0]
  def change
    add_column :advertisements, :payment_link, :string
  end
end
