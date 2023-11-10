class AddSeparatorsToMasks < ActiveRecord::Migration[7.0]
  def change
    add_column :masks, :thousands_separator, :string
    add_column :masks, :decimal_separator, :string
  end
end
