class ChangeDefaultTimeZone < ActiveRecord::Migration[7.0]
  def change
    change_column_default :users, :time_zone, 'Moscow'
  end
end
