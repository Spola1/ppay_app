# frozen_string_literal: true

class UpdateAdvertisementName < ActiveRecord::Migration[7.0]
  def change
    Advertisement.where(direction: 'продажа').update_all(direction: 'Deposit')
    Advertisement.where(direction: 'покупка').update_all(direction: 'Withdrawal')
  end
end
