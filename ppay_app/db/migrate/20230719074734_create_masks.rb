class CreateMasks < ActiveRecord::Migration[7.0]
  def change
    create_table :masks do |t|
      t.string :regexp_type
      t.string :regexp

      t.timestamps
    end
  end
end
