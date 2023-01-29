class AddDefaultValuesToAdvertisements < ActiveRecord::Migration[7.0]
  def change
    change_column :advertisements, :cryptocurrency, :string, default: 'USDT'
    change_column :advertisements, :payment_system_type, :integer, default: 0, using: 0
  end
end
