class AddConversionToAdvertisement < ActiveRecord::Migration[7.0]
  def change
    add_column :advertisements, :conversion, :decimal, default: nil
    add_column :advertisements, :completed_payments, :integer, default: nil
    add_column :advertisements, :cancelled_payments, :integer, default: nil
  end
end
