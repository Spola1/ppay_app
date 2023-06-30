# frozen_string_literal: true

class AddOtherBanksWithNationalCurrencies < ActiveRecord::Migration[7.0]
  def up
    NationalCurrency.all.each do |nc|
      nc.payment_systems.create(name: "Другой банк (#{nc})")
    end
  end
end
