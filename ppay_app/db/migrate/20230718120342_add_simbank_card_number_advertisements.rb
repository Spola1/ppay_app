class AddSimbankCardNumberAdvertisements < ActiveRecord::Migration[7.0]
  def change
    add_column :advertisements, :simbank_card_number, :string
  end
end
