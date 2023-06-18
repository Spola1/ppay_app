# frozen_string_literal: true

class AddPaymentWays < ActiveRecord::Migration[7.0]
  def up
    PaymentSystem.create(
      [
        { name: 'Dushanbe City - КортиМилли' },
        { name: 'Alif - VISA' },
        { name: 'Alif - КортиМилли' },
        { name: 'Спитамен - VISA' },
        { name: 'Спитамен - КортиМилли' }
      ]
    )

    PaymentWay.create(
      [
        { national_currency: 'RUB', payment_system: 'Sberbank' },
        { national_currency: 'RUB', payment_system: 'Tinkoff' },
        { national_currency: 'RUB', payment_system: 'Raiffeisen' },
        { national_currency: 'RUB', payment_system: 'AlfaBank' },
        { national_currency: 'UZS', payment_system: 'HUMO' },
        { national_currency: 'RUB', payment_system: 'Другой банк' },
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
      ].map { { national_currency: NationalCurrency.find_by(name: _1[:national_currency]),
                payment_system: PaymentSystem.find_by(name: _1[:payment_system]) } }
    )
  end
end
