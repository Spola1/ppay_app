# frozen_string_literal: true

class RemoveOtherBanksFromPaymentSystems < ActiveRecord::Migration[7.0]
  def up
    PaymentSystem.where("name ilike 'Другой банк (%'").destroy_all
  end
end
