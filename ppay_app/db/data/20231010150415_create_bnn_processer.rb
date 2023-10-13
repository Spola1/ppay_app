# frozen_string_literal: true

class CreateBnnProcesser < ActiveRecord::Migration[7.0]
  def up
    azn = NationalCurrency.find_or_create_by(name: 'AZN')

    bnn = Processer.create!(
      email: 'bnn@test.com',
      nickname: 'bnn',
      name: 'bnn',
      check_required: false,
      password: 'NQg6By9QncR5KssZ'
    )

    %w[ATBBank Azericard KapitalBank].each_with_index do |bank_name, i|
      PaymentSystem.create!(
        name: bank_name,
        national_currency: azn,
        exchange_portal: ExchangePortal.first
      )

      bnn.advertisements.create(
        direction: 'Deposit',
        national_currency: 'AZN',
        payment_system: bank_name,
        cryptocurrency: 'USDT',
        payment_system_type: 'card_number',
        card_number: "AZN0 0000 0000 000#{i}",
        processer_id: bnn.id,
        status: true
      )
    end

    RateSnapshot.create!(
      direction: 'buy',
      cryptocurrency: 'USDT',
      exchange_portal: ExchangePortal.first,
      payment_system: PaymentSystem.where(national_currency: azn).first,
      value: 1.7
    )
  end

  def down
    Processer.find_by(name: 'bnn')&.destroy
    NationalCurrency.find_by(name: 'AZN')&.destroy
  end
end
