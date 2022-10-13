# frozen_string_literal: true

class CreateExchangePortals < ActiveRecord::Migration[7.0]
  def change
    create_table :exchange_portals do |t|
      t.timestamps

      # название биржи
      t.string :name
    end
  end
end
