class CreateMasks < ActiveRecord::Migration[7.0]
  def change
    create_table :masks do |t|
      t.string :name
      t.string :sms_mask
      t.string :push_mask

      t.timestamps
    end
  end
end
