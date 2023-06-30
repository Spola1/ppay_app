# frozen_string_literal: true

class AddPaymentSystems < ActiveRecord::Migration[7.0]
  class PaymentSystem < ApplicationRecord; end

  def up
    PaymentSystem.create!(
      [
        { name: 'Sberbank' },
        { name: 'Tinkoff' },
        { name: 'Raiffeisen' },
        { name: 'AlfaBank' },
        { name: 'HUMO' }
      ]
    )
  end
end
