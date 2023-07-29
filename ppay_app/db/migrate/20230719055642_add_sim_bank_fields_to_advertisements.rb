class AddSimBankFieldsToAdvertisements < ActiveRecord::Migration[7.0]
  def change
    add_column :advertisements, :imei, :string
    add_column :advertisements, :phone, :string
    add_column :advertisements, :imsi, :string
    add_column :advertisements, :simbank_card_number, :string
  end
end
