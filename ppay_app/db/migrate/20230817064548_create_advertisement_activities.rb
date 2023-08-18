class CreateAdvertisementActivities < ActiveRecord::Migration[7.0]
  def change
    create_table :advertisement_activities do |t|
      t.references :advertisement, null: false, foreign_key: true
      t.datetime :deactivated_at

      t.timestamps
    end
  end
end
