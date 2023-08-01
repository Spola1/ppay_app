class AddSimbankAutoConfirmationToAdvertisements < ActiveRecord::Migration[7.0]
  def change
    add_column :advertisements, :simbank_auto_confirmation, :boolean, default: false
  end
end
