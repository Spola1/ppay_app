class CreateArbitrationResolutions < ActiveRecord::Migration[7.0]
  def change
    create_table :arbitration_resolutions do |t|
      t.references :payment, null: false, foreign_key: true
      t.integer :reason
      t.datetime :ended_at

      t.timestamps
    end
    add_index :arbitration_resolutions, :ended_at
  end
end
