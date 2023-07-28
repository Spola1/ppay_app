class AddSbpPhoneNumberAndCardOwnerNameToAdvertisements < ActiveRecord::Migration[7.0]
  def change
    add_column :advertisements, :sbp_phone_number, :string
    add_column :advertisements, :card_owner_name, :string
  end
end
