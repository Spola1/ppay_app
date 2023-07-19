class CreateMasks < ActiveRecord::Migration[7.0]
  def change
    create_table :masks do |t|
      t.string :app
      t.string :request_type
      t.string :mask

      t.timestamps
    end
  end
end
