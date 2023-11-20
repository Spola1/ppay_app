# frozen_string_literal: true

class AddPaymentSystems < ActiveRecord::Migration[7.0]
  class PaymentSystem < ApplicationRecord; end

  def up
    nc = NationalCurrency.find_or_create_by(name: 'RUB')
    payment_systems_data = [
      { name: 'Sberbank' },
      { name: 'Tinkoff' },
      { name: 'Raiffeisen' },
      { name: 'AlfaBank' },
      { name: 'HUMO' }
    ]

    ActiveRecord::Base.transaction do
      payment_systems = nc.payment_systems.create(payment_systems_data)

      create_rate_snapshots(payment_systems)
    end
  end

  def create_rate_snapshots(payment_systems)
    rate_snapshots_data = payment_systems.map do |payment_system|
      [
        { payment_system: payment_system, direction: 'buy', value: 100, exchange_portal_id: 1, cryptocurrency: 'USDT' },
        { payment_system: payment_system, direction: 'sell', value: 100, exchange_portal_id: 1, cryptocurrency: 'USDT' }
      ]
    end

    RateSnapshot.create(rate_snapshots_data)
  end
end
