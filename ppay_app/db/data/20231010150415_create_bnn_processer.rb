# frozen_string_literal: true

class CreateBnnProcesser < ActiveRecord::Migration[7.0]
  def up
    bnn = Processer.create(
      email: "bnn@test.com",
      nickname: "bnn",
      name: "bnn",
      password: 'NQg6By9QncR5KssZ',
      check_required: false
    )

    bnn.advertisements.create!(
      direction: 'deposit',
      national_currency: 'AZN',
      payment_system: 'ATBBank',
      cryptocurrency: 'USDT',
      payment_system_type: 'card_number',
      card_number: '1234123412341234',
      processer_id: bnn.id,
      status: true
    )

    bnn.advertisements.create!(
      direction: 'deposit',
      national_currency: 'AZN',
      payment_system: 'Azericard',
      cryptocurrency: 'USDT',
      payment_system_type: 'card_number',
      card_number: '1234333333333333',
      processer_id: bnn.id,
      status: true
    )

    bnn.advertisements.create!(
      direction: 'deposit',
      national_currency: 'AZN',
      payment_system: 'KapitalBank',
      cryptocurrency: 'USDT',
      payment_system_type: 'card_number',
      card_number: '1234444444444444',
      processer_id: bnn.id,
      status: true
    )
  end
end
