class AddSimbankIdentifierToAdvertisements < ActiveRecord::Migration[7.0]
  def change
    add_column :advertisements, :simbank_identifier, :string
  end
end
