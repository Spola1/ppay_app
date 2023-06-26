# frozen_string_literal: true

class AddNationalCurrenciesToPaymentSystems < ActiveRecord::Migration[7.0]
  def up
    tjs = NationalCurrency.find_by(name: 'TJS')
    PaymentSystem.create!(
      [
        { name: 'Dushanbe City - КортиМилли', national_currency: tjs },
        { name: 'Alif - VISA', national_currency: tjs },
        { name: 'Alif - КортиМилли', national_currency: tjs },
        { name: 'Спитамен - VISA', national_currency: tjs },
        { name: 'Спитамен - КортиМилли', national_currency: tjs }
      ]
    )

    [
      { national_currency: 'RUB', payment_system: 'Sberbank' },
      { national_currency: 'RUB', payment_system: 'Tinkoff' },
      { national_currency: 'RUB', payment_system: 'Raiffeisen' },
      { national_currency: 'RUB', payment_system: 'AlfaBank' },
      { national_currency: 'RUB', payment_system: 'Другой банк' },
      { national_currency: 'UZS', payment_system: 'HUMO' },
      { national_currency: 'KZT', payment_system: 'Банк ЦентрКредит' },
      { national_currency: 'KZT', payment_system: 'Halyk Bank' },
      { national_currency: 'KZT', payment_system: 'Jusan Bank' },
      { national_currency: 'KZT', payment_system: 'Kaspi Bank' },
      { national_currency: 'TRY', payment_system: 'IBAN' },
      { national_currency: 'UAH', payment_system: 'PrivatBank' },
      { national_currency: 'UAH', payment_system: 'MonoBank' },
      { national_currency: 'UAH', payment_system: 'PUMB' },
      { national_currency: 'IDR', payment_system: 'PermataBank' },
      { national_currency: 'KGS', payment_system: 'Optima24' },
      { national_currency: 'KGS', payment_system: 'Halyk' },
      { national_currency: 'KGS', payment_system: 'Bakai24' },
      { national_currency: 'KGS', payment_system: 'Demir' },
      { national_currency: 'UZS', payment_system: 'UzCard' },
      { national_currency: 'TJS', payment_system: 'Dushanbe City - КортиМилли' },
      { national_currency: 'TJS', payment_system: 'Alif - VISA' },
      { national_currency: 'TJS', payment_system: 'Alif - КортиМилли' },
      { national_currency: 'TJS', payment_system: 'Спитамен - VISA' },
      { national_currency: 'TJS', payment_system: 'Спитамен - КортиМилли' }
    ].each do |payment_system_currency|
      ps = PaymentSystem.find_by(name: payment_system_currency[:payment_system])
      ps.national_currency = NationalCurrency.find_by(name: payment_system_currency[:national_currency])
      ps.save!
    end
  end
end
